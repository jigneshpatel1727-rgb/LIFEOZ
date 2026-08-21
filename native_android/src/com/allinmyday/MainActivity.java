package com.allinmyday;

import android.app.Activity;
import android.content.Context;
import android.graphics.Canvas;
import android.graphics.Color;
import android.graphics.Paint;
import android.graphics.RadialGradient;
import android.graphics.Shader;
import android.os.Bundle;
import android.view.MotionEvent;
import android.view.View;

/**
 * Allinmyday native application surface.
 * Application layer uses Android platform APIs only: no Flutter, third-party
 * UI toolkit, third-party 3D engine, CDN, or runtime package.
 */
public final class MainActivity extends Activity {
    @Override public void onCreate(Bundle state) {
        super.onCreate(state);
        getWindow().setNavigationBarColor(Color.rgb(248, 250, 247));
        getWindow().setStatusBarColor(Color.rgb(248, 250, 247));
        getWindow().getDecorView().setSystemUiVisibility(View.SYSTEM_UI_FLAG_LIGHT_STATUS_BAR);
        setContentView(new AllinmydayView(this));
    }

    static final class AllinmydayView extends View {
        private final Paint paint = new Paint(Paint.ANTI_ALIAS_FLAG);
        private final Paint text = new Paint(Paint.ANTI_ALIAS_FLAG);
        private float yaw = 0f, pitch = 0f, lastX, lastY;
        private boolean dragging;
        private long start;

        // Five original Allinmyday core symbols. Geometry is intentionally simple,
        // calm and readable rather than neon or dashboard-heavy.
        private final float[][] cores = {
            {-0.62f, 0.20f, 0.10f}, {0.62f, 0.20f, 0.10f},
            {-0.45f,-0.34f, 0.00f}, {0.00f,-0.44f, 0.06f}, {0.45f,-0.34f,0.00f}
        };
        private final String[] labels = {"Expenses", "Goals", "Tasks", "Household", "Calendar"};
        private final int[] coreColors = {
            Color.rgb(91, 122, 91), Color.rgb(80, 112, 150), Color.rgb(126, 104, 146),
            Color.rgb(190, 132, 74), Color.rgb(74, 135, 150)
        };

        AllinmydayView(Context c) {
            super(c);
            text.setTypeface(android.graphics.Typeface.create("sans", android.graphics.Typeface.NORMAL));
            start = System.currentTimeMillis();
            setBackgroundColor(Color.rgb(248, 250, 247));
        }

        @Override protected void onDraw(Canvas c) {
            super.onDraw(c);
            final float w=getWidth(), h=getHeight(), cx=w*.5f, cy=h*.48f;
            final float t=(System.currentTimeMillis()-start)/1000f;
            drawBackground(c,w,h);

            // Quiet spatial links: barely visible, intended to suggest a living system.
            for(int i=0;i<cores.length;i++) {
                Point q=project(cores[i][0],cores[i][1],cores[i][2],cx,cy,w,h);
                Point y=project(0,0,0.12f,cx,cy,w,h);
                paint.setStyle(Paint.Style.STROKE);
                paint.setStrokeWidth(1.0f);
                paint.setColor(Color.argb(55, 75, 110, 85));
                c.drawLine(y.x,y.y,q.x,q.y,paint);
                paint.setStyle(Paint.Style.FILL);
            }

            Point center=project(0,0,0.12f,cx,cy,w,h);
            float pulse=1f+.025f*(float)Math.sin(t*1.7);
            drawOrb(c,center.x,center.y,Math.min(w,h)*.105f*pulse);
            drawText(c,"iamyansi",center.x,center.y+5,17,Color.rgb(38,66,50),Paint.Align.CENTER);

            for(int i=0;i<cores.length;i++) {
                Point q=project(cores[i][0],cores[i][1],cores[i][2],cx,cy,w,h);
                drawCore(c,q.x,q.y,Math.min(w,h)*.040f,coreColors[i]);
                drawText(c,labels[i],q.x,q.y+Math.min(w,h)*.070f,11,Color.rgb(62,72,66),Paint.Align.CENTER);
            }

            drawText(c,"ALLINMYDAY",22,38,18,Color.rgb(38,66,50),Paint.Align.LEFT);
            drawText(c,"One screen. One tap. One report.",22,59,10,Color.rgb(100,112,103),Paint.Align.LEFT);
            drawText(c,"DRAG TO EXPLORE",w-22,h-24,10,Color.rgb(100,112,103),Paint.Align.RIGHT);
            postInvalidateDelayed(32);
        }

        private void drawBackground(Canvas c,float w,float h) {
            paint.setShader(new RadialGradient(w*.5f,h*.40f,Math.max(w,h)*.72f,
                new int[]{Color.rgb(255,255,253),Color.rgb(248,250,247),Color.rgb(238,244,238)},
                null,Shader.TileMode.CLAMP));
            c.drawRect(0,0,w,h,paint);
            paint.setShader(null);
            paint.setColor(Color.argb(20,70,105,80));
            c.drawCircle(w*.16f,h*.78f,Math.min(w,h)*.20f,paint);
            c.drawCircle(w*.86f,h*.24f,Math.min(w,h)*.17f,paint);
        }

        private void drawOrb(Canvas c,float x,float y,float r) {
            paint.setShader(new RadialGradient(x-r*.22f,y-r*.24f,r,
                new int[]{Color.WHITE,Color.rgb(229,239,230),Color.rgb(183,205,187),Color.TRANSPARENT},
                new float[]{0f,.35f,.72f,1f},Shader.TileMode.CLAMP));
            c.drawCircle(x,y,r,paint); paint.setShader(null);
            paint.setStyle(Paint.Style.STROKE); paint.setStrokeWidth(1.2f);
            paint.setColor(Color.argb(100,82,116,91));
            c.drawCircle(x,y,r*1.22f,paint); c.drawCircle(x,y,r*1.43f,paint);
            paint.setStyle(Paint.Style.FILL);
        }

        private void drawCore(Canvas c,float x,float y,float r,int color) {
            paint.setColor(Color.argb(22,Color.red(color),Color.green(color),Color.blue(color)));
            c.drawCircle(x,y,r*1.8f,paint);
            paint.setColor(color); c.drawCircle(x,y,r,paint);
            paint.setStyle(Paint.Style.STROKE); paint.setStrokeWidth(1.0f);
            paint.setColor(Color.argb(100,Color.red(color),Color.green(color),Color.blue(color)));
            c.drawCircle(x,y,r*1.32f,paint); paint.setStyle(Paint.Style.FILL);
        }

        private Point project(float x,float y,float z,float cx,float cy,float w,float h) {
            float cY=(float)Math.cos(yaw), sY=(float)Math.sin(yaw);
            float X=x*cY-z*sY, Z=x*sY+z*cY;
            float cX=(float)Math.cos(pitch), sX=(float)Math.sin(pitch);
            float Y=y*cX-Z*sX, D=1.55f-(y*sX+Z*cX)*.18f;
            float scale=Math.min(w,h)*.72f/D;
            return new Point(cx+X*scale,cy-Y*scale);
        }

        private void drawText(Canvas c,String s,float x,float y,float size,int color,Paint.Align align) {
            text.setTextSize(size); text.setColor(color); text.setTextAlign(align); c.drawText(s,x,y,text);
        }

        @Override public boolean onTouchEvent(MotionEvent e) {
            switch(e.getActionMasked()) {
                case MotionEvent.ACTION_DOWN: dragging=true; lastX=e.getX(); lastY=e.getY(); return true;
                case MotionEvent.ACTION_MOVE:
                    if(dragging) {
                        yaw+=(e.getX()-lastX)*.004f;
                        pitch+=(e.getY()-lastY)*.003f;
                        pitch=Math.max(-.55f,Math.min(.55f,pitch));
                        lastX=e.getX(); lastY=e.getY(); invalidate();
                    }
                    return true;
                case MotionEvent.ACTION_UP: dragging=false; performClick(); return true;
            }
            return true;
        }
        @Override public boolean performClick(){ super.performClick(); return true; }
        static final class Point { final float x,y; Point(float x,float y){this.x=x;this.y=y;} }
    }
}
