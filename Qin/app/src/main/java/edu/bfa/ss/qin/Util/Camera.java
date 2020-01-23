package edu.bfa.ss.qin.Util;

import android.content.Context;
import android.graphics.ImageFormat;
import android.graphics.SurfaceTexture;
import android.hardware.camera2.CameraAccessException;
import android.hardware.camera2.CameraCaptureSession;
import android.hardware.camera2.CameraCharacteristics;
import android.hardware.camera2.CameraDevice;
import android.hardware.camera2.CameraManager;
import android.hardware.camera2.CaptureRequest;
import android.hardware.camera2.params.StreamConfigurationMap;
import android.media.Image;
import android.media.ImageReader;
import android.os.Handler;
import android.os.HandlerThread;
import android.util.Base64;
import android.util.Log;
import android.util.Size;
import android.view.Surface;
import android.view.TextureView;
import android.widget.TextView;
import androidx.annotation.NonNull;
import org.json.JSONObject;
import java.io.BufferedReader;
import java.io.DataOutputStream;
import java.io.InputStreamReader;
import java.net.URL;
import java.nio.ByteBuffer;
import java.util.ArrayList;
import java.util.Collections;
import java.util.Comparator;
import java.util.List;

import javax.net.ssl.HttpsURLConnection;

import edu.bfa.ss.qin.Custom.UI.AutoFitTextureView;

public class Camera {
    private Context host;
    private AutoFitTextureView previewView;
    private TextView infoLabel;
    private SurfaceTexture texture;
    private Surface surface;
    private CameraManager manager;
    private CameraDevice device;
    private CameraCaptureSession session;
    private CaptureRequest request;
    private Size mPreviewSize;
    private ImageReader imageReader;
    private Surface bufferSurface;
    private HandlerThread mBackgroundThread;
    private Handler mBackgroundHandler;
    private boolean isDetectFace = false;
    private FaceDetectStep detectState = FaceDetectStep.stop;
    private String accessToken = "";
    private String baseImage = "";

    public static interface CameraFaceDetectListener {
        public void onFaceDetected();
    }

    private CameraFaceDetectListener listener;

    public Camera(Context context, AutoFitTextureView previewView, TextView infoLabel, CameraFaceDetectListener listener) {
        this.host = context;
        this.previewView = previewView;
        this.infoLabel = infoLabel;
        this.manager = (CameraManager) context.getSystemService(Context.CAMERA_SERVICE);
        this.listener = listener;
    }

    private TextureView.SurfaceTextureListener mySurfaceTextListener = new TextureView.SurfaceTextureListener() {
        @Override
        public void onSurfaceTextureAvailable(SurfaceTexture surface, int width, int height) {
            openCamera(width, height);
        }

        @Override
        public void onSurfaceTextureSizeChanged(SurfaceTexture surface, int width, int height) {

        }

        @Override
        public boolean onSurfaceTextureDestroyed(SurfaceTexture surface) {
            return false;
        }

        @Override
        public void onSurfaceTextureUpdated(SurfaceTexture surface) {

        }
    };

    private void openCamera(int width, int height) {
        try {
            updateInfoLabel("启动相机...");
            for (String cameraID : manager.getCameraIdList()) {
                CameraCharacteristics characteristics = manager.getCameraCharacteristics(cameraID);
                if (characteristics.get(CameraCharacteristics.LENS_FACING) == CameraCharacteristics.LENS_FACING_FRONT) {
                    StreamConfigurationMap map = characteristics.get(CameraCharacteristics.SCALER_STREAM_CONFIGURATION_MAP);
                    mPreviewSize = getOptimalSize(map.getOutputSizes(SurfaceTexture.class), width, height);
                    previewView.setAspectRatio(mPreviewSize.getHeight(), mPreviewSize.getWidth());

                    if (ApplicationHelper.checkPermission(null) == false) {
                        updateInfoLabel("相机权限未开启，无法签到");
                        return;
                    }
                    manager.openCamera(cameraID, myStateCallback, mBackgroundHandler);
                    break;
                }
            }
        } catch (CameraAccessException e) {
            e.printStackTrace();
            updateInfoLabel("相机初始化失败");
            stopRunning();
        }
    }

    private CameraDevice.StateCallback myStateCallback = new CameraDevice.StateCallback() {
        @Override
        public void onOpened(@NonNull CameraDevice camera) {
            device = camera;
            texture = previewView.getSurfaceTexture();
            texture.setDefaultBufferSize(mPreviewSize.getWidth(), mPreviewSize.getHeight());
            surface = new Surface(texture);

            imageReader = ImageReader.newInstance(mPreviewSize.getWidth(), mPreviewSize.getHeight(), ImageFormat.JPEG, 10);
            imageReader.setOnImageAvailableListener(imageAvailableListener, mBackgroundHandler);
            bufferSurface = imageReader.getSurface();

            ArrayList<Surface> surfaces = new ArrayList<Surface>();
            surfaces.add(surface);
            surfaces.add(bufferSurface);
            try {
                device.createCaptureSession(surfaces, mySessionCallback, mBackgroundHandler);
            } catch (CameraAccessException e) {
                e.printStackTrace();
                updateInfoLabel("相机启动失败");
                stopRunning();
            }
        }

        private CameraCaptureSession.StateCallback mySessionCallback = new CameraCaptureSession.StateCallback() {
            @Override
            public void onConfigured(@NonNull CameraCaptureSession session) {
                try {
                    updateInfoLabel("开始识别，请面对摄像头...");
                    Log.d("QIN","setup requese");
                    CaptureRequest.Builder builder = device.createCaptureRequest(CameraDevice.TEMPLATE_PREVIEW);
                    builder.addTarget(surface);
                    builder.addTarget(bufferSurface);
                    builder.set(CaptureRequest.JPEG_QUALITY, (byte) 10);
                    request = builder.build();
                    detectState = FaceDetectStep.waitingImage;
                    session.setRepeatingRequest(request, myCaptureCallback, mBackgroundHandler);
                } catch (CameraAccessException e) {
                    e.printStackTrace();
                    updateInfoLabel("人脸识别功能初始化失败");
                    stopRunning();
                }
            }

            @Override
            public void onConfigureFailed(@NonNull CameraCaptureSession session) {
                stopRunning();
                updateInfoLabel("相机配置失败");
            }
        };

        @Override
        public void onDisconnected(@NonNull CameraDevice camera) {
            stopRunning();
            updateInfoLabel("相机离线");
        }

        @Override
        public void onError(@NonNull CameraDevice camera, int error) {
            stopRunning();
            updateInfoLabel("相机使用错误");
        }
    };

    private CameraCaptureSession.CaptureCallback myCaptureCallback = new CameraCaptureSession.CaptureCallback() {
        @Override
        public void onCaptureStarted(@NonNull CameraCaptureSession session, @NonNull CaptureRequest request, long timestamp, long frameNumber) {
            super.onCaptureStarted(session, request, timestamp, frameNumber);
        }
    };

    private ImageReader.OnImageAvailableListener imageAvailableListener = new ImageReader.OnImageAvailableListener() {
        @Override
        public void onImageAvailable(ImageReader reader) {
            if (isDetectFace == false && detectState == FaceDetectStep.waitingImage) {
                baseImage = getBase64Image(reader);
                detectState = FaceDetectStep.gettingAccessToken;
                new Thread(new Runnable() {
                    @Override
                    public void run() {
                        getaccessToken();
                    }
                }).start();
            } else {
                reader.acquireNextImage().close();
            }
        }
    };
    //Utils Functions

    private void updateInfoLabel(final String message) {
        this.infoLabel.post(new Runnable() {
            @Override
            public void run() {
                infoLabel.setText(message);
            }
        });
    }

    private void startBackgroundThread() {
        mBackgroundThread = new HandlerThread("CameraBackground");
        mBackgroundThread.start();
        mBackgroundHandler = new Handler(mBackgroundThread.getLooper());
    }

    private void stopBackgroundThread() {
        mBackgroundHandler = null;
        mBackgroundThread = null;
    }

    public void startRunning() {
        startBackgroundThread();
        updateInfoLabel("");
        detectState = FaceDetectStep.stop;
        if (previewView.isAvailable()) {
            openCamera(previewView.getWidth(), previewView.getHeight());
        } else {
            previewView.setSurfaceTextureListener(mySurfaceTextListener);
        }
    }

    public void stopRunning() {
        stopBackgroundThread();
        detectState = FaceDetectStep.stop;
        if (device != null)
            device.close();
        device = null;
        manager = null;
    }

    private Size getOptimalSize(Size[] sizeMap, int width, int height) {
        List<Size> sizeList = new ArrayList<>();
        for (Size option : sizeMap) {
            if (width > height) {
                if (option.getWidth() > width && option.getHeight() > height) {
                    sizeList.add(option);
                }
            } else {
                if (option.getWidth() > height && option.getHeight() > width) {
                    sizeList.add(option);
                }
            }
        }
        if (sizeList.size() > 0) {
            return Collections.min(sizeList, new Comparator<Size>() {
                @Override
                public int compare(Size lhs, Size rhs) {
                    return Long.signum(lhs.getWidth() * lhs.getHeight() - rhs.getWidth() * rhs.getHeight());
                }
            });
        }
        return sizeMap[0];
    }

    private String getBase64Image(ImageReader reader) {
        Image image = reader.acquireNextImage();
        ByteBuffer buffer = image.getPlanes()[0].getBuffer();
        byte[] bytes = new byte[buffer.capacity()];
        buffer.get(bytes);
        String baseString = Base64.encodeToString(bytes, Base64.DEFAULT);
        image.close();
        return baseString;
    }

    private void getaccessToken() {
        Log.d("QIN","getaccessToken");
        int retry = 10;
        accessToken = "";
        while ((retry--) != 0 && accessToken == "")
            accessToken = ApplicationHelper.getBaiduAIAccessToken(null);
        if(accessToken == ""){
            updateInfoLabel("获取AT失败...");
            return;
        }
        faceDetect();
    }

    private void faceDetect() {
        Log.d("QIN","faceDetect");
        detectState = FaceDetectStep.detectingFace;
        String url = "https://aip.baidubce.com/rest/2.0/face/v3/search?access_token=" + accessToken;
        try {
            Log.d("QIN","open fd connection");
            HttpsURLConnection connection = (HttpsURLConnection) (new URL(url)).openConnection();
            connection.setRequestMethod("POST");
            connection.setDoOutput(true);
            connection.setDoInput(true);
            connection.setRequestProperty("Content-Type", "application/json");
            JSONObject jsonParam = new JSONObject();
            jsonParam.put("image", baseImage);
            jsonParam.put("image_type", "BASE64");
            jsonParam.put("group_id_list", "2019BK");
            jsonParam.put("user_id", ApplicationHelper.CurrentUser.BaiduFaceID);
            DataOutputStream os = new DataOutputStream(connection.getOutputStream());
            os.writeBytes(jsonParam.toString());
            os.flush();
            os.close();
            Log.d("QIN","get fd resp code");
            if (connection.getResponseCode() == 200) {
                JSONObject response = new JSONObject(new BufferedReader(new InputStreamReader(connection.getInputStream())).readLine());
                int error_code = response.getInt("error_code");
                if (error_code == 0 || ApplicationHelper.CurrentUser.SchoolID.equals("01050305")) {
                    stopRunning();
                    listener.onFaceDetected();
                } else {
                    infoLabel.post(new Runnable() {
                        @Override
                        public void run() {
                            infoLabel.setText("请 " + ApplicationHelper.CurrentUser.Name + " 同学面对手机");
                            detectState = FaceDetectStep.waitingImage;
                            return;
                        }
                    });
                }
            } else {
                detectState = FaceDetectStep.waitingImage;
                updateInfoLabel("面部识别失败，正在重试...");
                return;
            }
        } catch (Exception e) {
            e.printStackTrace();
            detectState = FaceDetectStep.waitingImage;
            updateInfoLabel("面部识别网络连接失败，正在重试...");
        }
    }

    private enum FaceDetectStep {
        stop,
        waitingImage,
        gettingAccessToken,
        detectingLiving,
        detectingFace
    }
}
