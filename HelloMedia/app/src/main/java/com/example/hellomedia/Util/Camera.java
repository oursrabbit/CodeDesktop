package com.example.hellomedia.Util;

import android.Manifest;
import android.content.Context;
import android.content.Intent;
import android.content.pm.PackageManager;
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

import androidx.annotation.NonNull;

import com.android.volley.AuthFailureError;
import com.android.volley.Request;
import com.android.volley.RequestQueue;
import com.android.volley.Response;
import com.android.volley.VolleyError;
import com.android.volley.toolbox.JsonArrayRequest;
import com.android.volley.toolbox.JsonObjectRequest;
import com.android.volley.toolbox.JsonRequest;
import com.android.volley.toolbox.Volley;
import com.example.hellomedia.CheckDBActivity;
import com.example.hellomedia.Custom.UI.AutoFitTextureView;
import com.example.hellomedia.FaceDetectActivity;
import com.example.hellomedia.IndexActivity;
import com.example.hellomedia.ScannerActivity;

import org.json.JSONArray;
import org.json.JSONException;
import org.json.JSONObject;

import java.io.Console;
import java.nio.ByteBuffer;
import java.util.ArrayList;
import java.util.Collections;
import java.util.Comparator;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

public class Camera {
    private enum  FaceDetectStep {
        stop,
        waitingImage,
        gettingAccessToken,
        detectingLiving,
        detectingFace
    }

    private Context host;
    private AutoFitTextureView previewView;
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

    private RequestQueue queue;

    private boolean isDetectFace = false;
    private FaceDetectStep detectState =  FaceDetectStep.stop;
    private String accessToken = "";
    private String baseImage = "";

    public Camera(Context context, AutoFitTextureView previewView) {
        host = context;
        this.previewView = previewView;
        manager = (CameraManager) context.getSystemService(Context.CAMERA_SERVICE);
        queue = Volley.newRequestQueue(this.previewView.getContext());
    }

    private void startBackgroundThread() {
        mBackgroundThread = new HandlerThread("CameraBackground");
        mBackgroundThread.start();
        mBackgroundHandler = new Handler(mBackgroundThread.getLooper());
    }

    public void startRunning(){
        startBackgroundThread();
        if (previewView.isAvailable()) {
            openCamera(previewView.getWidth(), previewView.getHeight());
        } else {
            previewView.setSurfaceTextureListener(mySurfaceTextListener);
        }
    }

    public void stopRunning() {
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
            for (String cameraID : manager.getCameraIdList()) {
                CameraCharacteristics characteristics = manager.getCameraCharacteristics(cameraID);
                if (characteristics.get(CameraCharacteristics.LENS_FACING) == CameraCharacteristics.LENS_FACING_FRONT) {
                    StreamConfigurationMap map = characteristics.get(CameraCharacteristics.SCALER_STREAM_CONFIGURATION_MAP);
                    //根据TextureView的尺寸设置预览尺寸
                    mPreviewSize = getOptimalSize(map.getOutputSizes(SurfaceTexture.class), width, height);
                    previewView.setAspectRatio(mPreviewSize.getHeight(), mPreviewSize.getWidth());
                    manager.openCamera(cameraID, myStateCallback, mBackgroundHandler);
                    break;
                }
            }
        } catch (CameraAccessException e) {
            e.printStackTrace();
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
            }
        }

        @Override
        public void onDisconnected(@NonNull CameraDevice camera) {

        }

        @Override
        public void onError(@NonNull CameraDevice camera, int error) {

        }
    };

    private CameraCaptureSession.StateCallback mySessionCallback = new CameraCaptureSession.StateCallback() {
        @Override
        public void onConfigured(@NonNull CameraCaptureSession session) {
            try {
                CaptureRequest.Builder builder = device.createCaptureRequest(CameraDevice.TEMPLATE_PREVIEW);
                builder.addTarget(surface);
                builder.addTarget(bufferSurface);
                builder.set(CaptureRequest.JPEG_QUALITY, (byte)10);
                request = builder.build();
                detectState = FaceDetectStep.waitingImage;
                session.setRepeatingRequest(request, myCaptureCallback, mBackgroundHandler);
            } catch (CameraAccessException e) {
                e.printStackTrace();
            }
        }

        @Override
        public void onConfigureFailed(@NonNull CameraCaptureSession session) {

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
            baseImage = getBase64Image(reader);
            if (isDetectFace == false && detectState == FaceDetectStep.waitingImage){
                detectState = FaceDetectStep.gettingAccessToken;
                new Thread(new Runnable() {
                    @Override
                    public void run() {
                        try {
                            Thread.sleep(500);
                        } catch (InterruptedException e) {
                            e.printStackTrace();
                        }
                        getaccessToken();
                    }
                }).start();
            }
        }
    };

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
        String url = "https://aip.baidubce.com/oauth/2.0/token?grant_type=client_credentials&client_id=CGFGbXrchcUA0KwfLTpCQG0T&client_secret=IyGcGlMoB26U1Zf2s2qX05O9dETGGxHg";
        RequestQueue session = Volley.newRequestQueue(this.previewView.getContext());
        session.add(new JsonObjectRequest
                (Request.Method.POST, url, null, new Response.Listener<JSONObject>() {
                    @Override
                    public void onResponse(JSONObject response) {
                        try {
                            accessToken = response.getString("access_token");
                            Log.d("getaccessToken", accessToken);
                        } catch (JSONException e) {
                            e.printStackTrace();
                            detectState = FaceDetectStep.waitingImage;
                            return;
                        }
                        faceDetect();
                    }
                }, new Response.ErrorListener() {
                    @Override
                    public void onErrorResponse(VolleyError error) {
                        // TODO: Handle error
                        error.printStackTrace();
                        detectState = FaceDetectStep.waitingImage;
                    }
                }));
    }

    private void faceDetect() {
        detectState = FaceDetectStep.detectingFace;
        String url = "https://aip.baidubce.com/rest/2.0/face/v3/search?access_token=" + accessToken;
        HashMap<String,String> jsonString = new HashMap<String, String>();
        jsonString.put("image",baseImage);
        jsonString.put("image_type","BASE64");
        jsonString.put("group_id_list","2019BK");
        jsonString.put("user_id",StaticData.StudentID);
        queue.add(new JsonObjectRequest
                (Request.Method.POST, url, new JSONObject(jsonString), new Response.Listener<JSONObject>() {
                    @Override
                    public void onResponse(JSONObject response) {
                        try {
                            int error_code = response.getInt("error_code");
                            if (error_code == 0){
                                stopRunning();
                                Intent intent = new Intent();
                                intent.setClass(host, ScannerActivity.class);
                                host.startActivity(intent);
                            }else {
                                Log.d("JsonObjectRequest", response.toString());
                            }
                        } catch (JSONException e) {
                            e.printStackTrace();
                            detectState = FaceDetectStep.waitingImage;
                        }
                    }
                }, new Response.ErrorListener() {
                    @Override
                    public void onErrorResponse(VolleyError error) {
                        // TODO: Handle error
                        error.printStackTrace();
                        detectState = FaceDetectStep.waitingImage;
                    }
                }){
            @Override
            public Map<String, String> getHeaders() throws AuthFailureError {
                Map<String,String> header = new HashMap<>();
                header.put("Content-Type", "application/json");
                return header;
            }
        });
    }
}
