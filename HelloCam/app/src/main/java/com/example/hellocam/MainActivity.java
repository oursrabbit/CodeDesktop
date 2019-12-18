package com.example.hellocam;

import androidx.annotation.NonNull;
import androidx.annotation.Nullable;
import androidx.appcompat.app.AppCompatActivity;

import android.content.Context;
import android.graphics.Bitmap;
import android.graphics.BitmapFactory;
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
import android.os.Bundle;
import android.util.Base64;
import android.util.Log;
import android.util.Size;
import android.view.Surface;
import android.view.TextureView;

import java.nio.ByteBuffer;
import java.util.ArrayList;
import java.util.Collection;
import java.util.Collections;
import java.util.Comparator;
import java.util.Iterator;
import java.util.List;
import java.util.ListIterator;

public class MainActivity extends AppCompatActivity {

    private AutoFitTextureView preView;
    private SurfaceTexture texture;
    private Surface surface;
    private CameraManager manager;
    private CameraDevice device;
    private CameraCaptureSession session;
    private CaptureRequest request;
    private Size mPreviewSize;
    private ImageReader imageReader;
    private Surface bufferSurface;

    //选择sizeMap中大于并且最接近width和height的size
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
            try {
                for (String cameraID: manager.getCameraIdList()) {
                    CameraCharacteristics characteristics = manager.getCameraCharacteristics(cameraID);
                    if(characteristics.get(CameraCharacteristics.LENS_FACING) == CameraCharacteristics.LENS_FACING_FRONT){
                        StreamConfigurationMap map = characteristics.get(CameraCharacteristics.SCALER_STREAM_CONFIGURATION_MAP);
                        //根据TextureView的尺寸设置预览尺寸
                        mPreviewSize = getOptimalSize(map.getOutputSizes(SurfaceTexture.class), width, height);
                        preView.setAspectRatio(mPreviewSize.getHeight(), mPreviewSize.getWidth());
                        manager.openCamera(cameraID, myStateCallback,null);
                        break;
                    }
                }
            } catch (CameraAccessException e) {
                e.printStackTrace();
            }
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

    private CameraCaptureSession.CaptureCallback myCaptureCallback = new CameraCaptureSession.CaptureCallback() {
        @Override
        public void onCaptureStarted(@NonNull CameraCaptureSession session, @NonNull CaptureRequest request, long timestamp, long frameNumber) {
            super.onCaptureStarted(session, request, timestamp, frameNumber);
        }
    };
    private CameraCaptureSession.StateCallback mySessionCallback = new CameraCaptureSession.StateCallback() {
        @Override
        public void onConfigured(@NonNull CameraCaptureSession session) {
            try {
                CaptureRequest.Builder builder = device.createCaptureRequest(CameraDevice.TEMPLATE_PREVIEW);
                builder.addTarget(surface);
                builder.addTarget(bufferSurface);
                request = builder.build();
                session.setRepeatingRequest(request, myCaptureCallback, null);
            } catch (CameraAccessException e) {
                e.printStackTrace();
            }
        }

        @Override
        public void onConfigureFailed(@NonNull CameraCaptureSession session) {

        }
    };

    private ImageReader.OnImageAvailableListener imageAvailableListener = new ImageReader.OnImageAvailableListener() {
        @Override
        public void onImageAvailable(ImageReader reader) {
            Image image = reader.acquireNextImage();
            ByteBuffer buffer = image.getPlanes()[0].getBuffer();
            byte[] bytes = new byte[buffer.capacity()];
            buffer.get(bytes);
            String imageString = Base64.encodeToString(bytes, Base64.DEFAULT);
            image.close();
        }
    };

    private CameraDevice.StateCallback myStateCallback = new CameraDevice.StateCallback() {
        @Override
        public void onOpened(@NonNull CameraDevice camera) {
            device = camera;
            if(preView.isAvailable()){
                texture = preView.getSurfaceTexture();
                texture.setDefaultBufferSize(mPreviewSize.getWidth(), mPreviewSize.getHeight());
                surface = new Surface(texture);

                imageReader = ImageReader.newInstance(mPreviewSize.getWidth(),mPreviewSize.getHeight(), ImageFormat.JPEG, 10);
                imageReader.setOnImageAvailableListener(imageAvailableListener, null);
                bufferSurface=imageReader.getSurface();

                ArrayList<Surface> surfaces = new ArrayList<Surface>();
                surfaces.add(surface);
                surfaces.add(bufferSurface);
                try {
                    device.createCaptureSession(surfaces,mySessionCallback, null);
                } catch (CameraAccessException e) {
                    e.printStackTrace();
                }
            }
        }

        @Override
        public void onDisconnected(@NonNull CameraDevice camera) {

        }

        @Override
        public void onError(@NonNull CameraDevice camera, int error) {

        }
    };

    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        setContentView(R.layout.activity_main);

        preView = (AutoFitTextureView)findViewById(R.id.textureView);
        preView.setSurfaceTextureListener(mySurfaceTextListener);

        manager = (CameraManager)getSystemService(Context.CAMERA_SERVICE);
    }
}
