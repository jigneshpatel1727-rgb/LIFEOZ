package com.allinmyday;

import android.app.Activity;
import android.os.Bundle;
import android.graphics.Canvas;
import android.graphics.Color;
import android.graphics.Paint;
import android.graphics.RadialGradient;
import android.graphics.LinearGradient;
import android.graphics.Shader;
import android.view.MotionEvent;
import android.view.View;
import android.content.Context;
import java.util.Locale;

/**
 * Allinmyday native trial surface.
 * No Flutter, third-party UI toolkit, CDN, or runtime library is used here.
 */
public final class MainActivity extends Activity {
    @Override public void onCreate(Bundle state) {
        super.onCreate(state);
        getWindow().setNavigationBarColor(Color.rgb(2,4,10));
        setContentView(new AllinmydayView(this));
    }

    static final class AllinmydayView extends View {
        private final Paint paint = new Paint(Paint.ANTI_ALIAS_FLAG);
        private final Paint text = new Paint(Paint.ANTI_ALIAS_FLAG);
        private float yaw = 0f, pitch = 0f, lastX, lastY;
        private boolean dragging;
        private long start;
        private final float[][] cores = {
            {-0.62f, 0.25f, 0.10f}, {0.62f, 0.25f, 0.10f},
            {-0.48f,-0.34f, 0.00f}, {0.00f,-0.46f, 0.06f}, {0.48f,-0.34f,0.00f}
        };
        private final int[] coreColors = {
            Color.rgb(255,190,90), Color.rgb(190,150,255), Color.rgb(100,235,135),
            Color.rgb(100,215,255), Color.rgb(255,150,105)
        };

        AllinmydayView(Context c) {
            super(c);
            setLayerType(View.LAYER_TYPE_SOFTWARE, null);
            text.setTypeface(android.graphics.Typeface.create("sans", android.graphics.Typeface.BOLD));
            start = System.currentTimeMillis();
            setBackgroundColor(Color.rgb(2,5,12));
        }

        @Override protected void onDraw(Canvas c) {
            super.onDraw(c);
            final float w=getWidth(), h=getHeight(), cx=w*.5f, cy=h*.51f;
            final float t=(System.currentTimeMillis()-start)/1000f;
            drawAtmosphere(c,cx,cy,w,h,t);
            for(int i=0;i<70;i++) {
                double a=i*2.39996+t*.018;
                float r=0.20f+(i%17)*0.045f;
                float px=(float)(Math.cos(a)*r), py=(float)(Math.sin(a)*r*.72);
                Point p=project(px,py,0.02f,cx,cy,w,h);
                paint.setColor(Color.argb(80+(i%3)*35,145,190,220));
                c.drawCircle(p.x,p.y,1.1f+(i%3)*.35f,paint);
            }
            // Soft spatial links. The cores intentionally use different materials/colours.
            for(int i=0;i<cores.length;i++) {
                Point q=project(cores[i][0],cores[i][1],cores[i][2],cx,cy,w,h);
                Point y=project(0,0,0.12f,cx,cy,w,h);
                paint.setStyle(Paint.Style.STROKE); paint.setStrokeWidth(1.3f);
                paint.setColor(Color.argb(80, coreColors[i]>>16&255, coreColors[i]>>8&255, coreColors[i]&255));
                c.drawLine(y.x,y.y,q.x,q.y,paint); paint.setStyle(Paint.Style.FILL);
            }
            // iamyansi living intelligence.
            Point center=project(0,0,0.12f,cx,cy,w,h);
            float pulse=1f+.08f*(float)Math.sin(t*2.1);
            drawOrb(c,center.x,center.y,Math.min(w,h)*.105f*pulse,t);
            drawText(c,"iamyansi",center.x,center.y+5,18,Color.WHITE,Paint.Align.CENTER);

            for(int i=0;i<cores.length;i++) {
                Point q=project(cores[i][0],cores[i][1],cores[i][2],cx,cy,w,h);
                float p=1f+.07f*(float)Math.sin(t*1.7+i);
                drawCore(c,q.x,q.y,Math.min(w,h)*.043f*p,coreColors[i],t+i);
            }
            drawText(c,"ALLINMYDAY",22,38,18,Color.WHITE,Paint.Align.LEFT);
            drawText(c,"immersive life intelligence",22,59,10,Color.argb(165,220,230,240),Paint.Align.LEFT);
            drawText(c,"DRAG TO EXPLORE  •  TAP A CORE",w-22,h-24,10,Color.argb(150,220,230,240),Paint.Align.RIGHT);
        }

        private void drawAtmosphere(Canvas c,float cx,float cy,float w,float h,float t) {
            paint.setShader(new RadialGradient(cx,cy*.82f,Math.max(w,h)*.72f,
                new int[]{Color.rgb(12,20,35),Color.rgb(3,8,17),Color.rgb(1,3,8)},null,Shader.TileMode.CLAMP));
            c.drawRect(0,0,w,h,paint); paint.setShader(null);
            for(int i=0;i<5;i++) {
                float x=w*(.16f+i*.18f)+(float)Math.sin(t*.12f+i)*12;
                float y=h*(.18f+(i%3)*.27f);
                paint.setColor(Color.argb(18,90,170,220)); c.drawCircle(x,y,70+i*15,paint);
            }
        }

        private void drawOrb(Canvas c,float x,float y,float r,float t) {
            paint.setShader(new RadialGradient(x-r*.18f,y-r*.22f,r,
                new int[]{Color.WHITE,Color.rgb(130,215,255),Color.rgb(35,85,125),Color.TRANSPARENT},
                new float[]{0f,.18f,.58f,1f},Shader.TileMode.CLAMP));
            c.drawCircle(x,y,r,paint); paint.setShader(null);
            paint.setStyle(Paint.Style.STROKE); paint.setStrokeWidth(1.5f);
            paint.setColor(Color.argb(180,160,225,255));
            c.drawCircle(x,y,r*1.22f,paint); c.drawCircle(x,y,r*1.43f,paint);
            paint.setStyle(Paint.Style.FILL);
        }

        private void drawCore(Canvas c,float x,float y,float r,int color,float phase) {
            paint.setShadowLayer(r*1.6f,0,0,Color.argb(90,Color.red(color),Color.green(color),Color.blue(color)));
            paint.setColor(Color.argb(235,Color.red(color),Color.green(color),Color.blue(color))); c.drawCircle(x,y,r,paint);
            paint.clearShadowLayer();
            paint.setStyle(Paint.Style.STROKE); paint.setStrokeWidth(1.1f); paint.setColor(Color.argb(180,255,255,255));
            c.drawCircle(x,y,r*1.35f,paint); paint.setStyle(Paint.Style.FILL);
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
                    if(dragging) { yaw+=(e.getX()-lastX)*.004f; pitch+=(e.getY()-lastY)*.003f; pitch=Math.max(-.55f,Math.min(.55f,pitch)); lastX=e.getX(); lastY=e.getY(); invalidate(); }
                    return true;
                case MotionEvent.ACTION_UP: dragging=false; performClick(); return true;
            }
            return true;
        }
        @Override public boolean performClick(){ super.performClick(); return true; }
        static final class Point { final float x,y; Point(float x,float y){this.x=x;this.y=y;} }
    }
}
