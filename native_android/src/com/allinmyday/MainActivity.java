package com.allinmyday;

import android.app.Activity;
import android.app.AlertDialog;
import android.content.Context;
import android.graphics.Canvas;
import android.graphics.Color;
import android.graphics.Paint;
import android.graphics.RadialGradient;
import android.graphics.Shader;
import android.os.Bundle;
import android.text.InputType;
import android.view.Gravity;
import android.view.MotionEvent;
import android.view.View;
import android.widget.Button;
import android.widget.EditText;
import android.widget.LinearLayout;
import android.widget.Spinner;
import android.widget.ArrayAdapter;
import android.widget.TextView;
import android.widget.Toast;

/** Allinmyday native application surface. iamyansi remains invisible/ambient. */
public final class MainActivity extends Activity {
    private IamyansiCore iamyansi;
    private AllinmydayStore store;
    private final int green = Color.rgb(55, 96, 61);
    private final int ink = Color.rgb(42, 55, 45);
    private final int bg = Color.rgb(248, 250, 247);

    @Override public void onCreate(Bundle state) {
        super.onCreate(state);
        getWindow().setNavigationBarColor(bg);
        getWindow().setStatusBarColor(bg);
        getWindow().getDecorView().setSystemUiVisibility(View.SYSTEM_UI_FLAG_LIGHT_STATUS_BAR);
        iamyansi = new IamyansiCore();
        store = new AllinmydayStore(this);
        if (store.hasProfile()) showHome(); else showOnboarding();
    }

    private TextView label(String value, float size) {
        TextView t = new TextView(this); t.setText(value); t.setTextSize(size); t.setTextColor(ink); t.setPadding(0, 8, 0, 8); return t;
    }

    private Button action(String value) {
        Button b = new Button(this); b.setText(value); b.setTextColor(Color.WHITE); b.setBackgroundColor(green); b.setAllCaps(false); return b;
    }

    private void showOnboarding() {
        LinearLayout root = new LinearLayout(this); root.setOrientation(LinearLayout.VERTICAL); root.setPadding(36, 42, 36, 28); root.setBackgroundColor(bg);
        TextView brand = label("ALLINMYDAY", 30); brand.setTextColor(green); brand.setTypeface(null, android.graphics.Typeface.BOLD); root.addView(brand);
        root.addView(label("One screen. One tap. One report.", 14));
        root.addView(label("\nWelcome. Let's set up your private LifeOS profile.", 22));
        root.addView(label("Your information is stored locally on this device in this native trial.", 14));
        EditText name = new EditText(this); name.setHint("Your name"); root.addView(name);
        EditText email = new EditText(this); email.setHint("Email (optional)"); email.setInputType(InputType.TYPE_CLASS_TEXT | InputType.TYPE_TEXT_VARIATION_EMAIL_ADDRESS); root.addView(email);
        root.addView(label("Currency", 14));
        Spinner currency = new Spinner(this); currency.setAdapter(new ArrayAdapter<String>(this, android.R.layout.simple_spinner_dropdown_item, new String[]{"INR (₹)","USD ($)","EUR (€)","GBP (£)","AED (د.إ)"})); root.addView(currency);
        root.addView(label("Language", 14));
        Spinner language = new Spinner(this); language.setAdapter(new ArrayAdapter<String>(this, android.R.layout.simple_spinner_dropdown_item, new String[]{"English","Hindi","Gujarati"})); root.addView(language);
        root.addView(label("Theme", 14));
        Spinner theme = new Spinner(this); theme.setAdapter(new ArrayAdapter<String>(this, android.R.layout.simple_spinner_dropdown_item, new String[]{"Nature Green","Ocean Blue","Sunset Orange","Midnight Dark","Lavender Purple","Minimal White"})); root.addView(theme);
        Button continueButton = action("Create / Continue");
        LinearLayout.LayoutParams cp = new LinearLayout.LayoutParams(-1, 56); cp.topMargin = 24; root.addView(continueButton, cp);
        continueButton.setOnClickListener(v -> {
            String n = name.getText().toString().trim();
            if (n.isEmpty()) { name.setError("Enter your name"); return; }
            store.saveProfile(n, email.getText().toString(), currency.getSelectedItem().toString(), language.getSelectedItem().toString(), theme.getSelectedItem().toString());
            showHome();
        });
        setContentView(root);
    }

    private void showHome() {
        setContentView(new HomeView(this));
    }

    private void showProfile() {
        LinearLayout box = new LinearLayout(this); box.setOrientation(LinearLayout.VERTICAL); box.setPadding(32, 24, 32, 12);
        box.addView(label("Profile", 26));
        box.addView(label("Name: " + store.getName(), 17));
        box.addView(label("Email: " + (store.getEmail().isEmpty() ? "Not added" : store.getEmail()), 16));
        box.addView(label("Currency: " + store.getCurrency(), 16));
        box.addView(label("Language: " + store.getLanguage(), 16));
        box.addView(label("Theme: " + store.getTheme(), 16));
        new AlertDialog.Builder(this).setView(box).setPositiveButton("Edit", (d,w) -> showOnboarding()).setNegativeButton("Close", null).show();
    }

    private void openCore(int index) {
        final String[] cores = {"Expenses","Goals","Tasks","Household","Calendar"};
        final String core = cores[index];
        LinearLayout box = new LinearLayout(this); box.setOrientation(LinearLayout.VERTICAL); box.setPadding(28, 10, 28, 8);
        TextView info = label(core + "\n\nEverything for this core will live on one screen. Add, update and report from here.", 15); box.addView(info);
        EditText title = new EditText(this); title.setHint(index == 0 ? "Expense / description" : "Item / event / task"); title.setSingleLine(true); box.addView(title);
        EditText amount = new EditText(this); amount.setHint("Amount (optional)"); amount.setInputType(InputType.TYPE_CLASS_NUMBER | InputType.TYPE_NUMBER_FLAG_DECIMAL); amount.setSingleLine(true); box.addView(amount);
        new AlertDialog.Builder(this).setTitle(core).setView(box).setNegativeButton("Back", null).setPositiveButton("Save", (d,w) -> {
            String t = title.getText().toString().trim(); if (t.isEmpty()) { Toast.makeText(this, "Enter something first", Toast.LENGTH_SHORT).show(); return; }
            double a = 0; try { if (!amount.getText().toString().trim().isEmpty()) a = Double.parseDouble(amount.getText().toString().trim()); } catch(Exception ignored) {}
            store.addRecord(core, t, a, System.currentTimeMillis(), false);
            Toast.makeText(this, "Saved locally in " + core, Toast.LENGTH_SHORT).show();
        }).show();
    }

    @Override protected void onDestroy() { if (store != null) store.close(); super.onDestroy(); }

    final class HomeView extends View {
        private final Paint p = new Paint(Paint.ANTI_ALIAS_FLAG); private final Paint text = new Paint(Paint.ANTI_ALIAS_FLAG);
        private float yaw, pitch, lastX, lastY; private boolean dragging;
        private final float[][] cores = {{-.62f,.20f,.10f},{.62f,.20f,.10f},{-.45f,-.34f,0f},{0f,-.44f,.06f},{.45f,-.34f,0f}};
        private final String[] labels = {"Expenses","Goals","Tasks","Household","Calendar"};
        private final int[] colors = {Color.rgb(91,122,91),Color.rgb(80,112,150),Color.rgb(126,104,146),Color.rgb(190,132,74),Color.rgb(74,135,150)};
        HomeView(Context c) { super(c); text.setTypeface(android.graphics.Typeface.create("sans",0)); setBackgroundColor(bg); }
        @Override protected void onDraw(Canvas c) {
            float w=getWidth(), h=getHeight(), cx=w*.5f, cy=h*.48f; p.setShader(new RadialGradient(cx,cy,Math.max(w,h)*.75f,new int[]{Color.WHITE,bg,Color.rgb(238,244,238)},null,Shader.TileMode.CLAMP)); c.drawRect(0,0,w,h,p); p.setShader(null);
            drawText(c,"ALLINMYDAY",24,42,21,green,Paint.Align.LEFT); drawText(c,"One screen. One tap. One report.",24,62,11,Color.rgb(100,112,103),Paint.Align.LEFT);
            drawText(c,"Good day, " + store.getName(),24,102,20,ink,Paint.Align.LEFT); drawText(c,"Your life, organized quietly.",24,124,12,Color.rgb(100,112,103),Paint.Align.LEFT);
            drawText(c,"PROFILE",w-24,42,11,green,Paint.Align.RIGHT);
            Point center=project(0,0,.12f,cx,cy,w,h); // iamyansi is deliberately absent: ghost intelligence only.
            for(int i=0;i<cores.length;i++){ Point q=project(cores[i][0],cores[i][1],cores[i][2],cx,cy,w,h); p.setStyle(Paint.Style.STROKE);p.setStrokeWidth(1);p.setColor(Color.argb(45,75,110,85));c.drawLine(center.x,center.y,q.x,q.y,p);p.setStyle(Paint.Style.FILL); }
            for(int i=0;i<cores.length;i++){ Point q=project(cores[i][0],cores[i][1],cores[i][2],cx,cy,w,h); drawCore(c,q.x,q.y,Math.min(w,h)*.042f,colors[i]); drawText(c,labels[i],q.x,q.y+Math.min(w,h)*.070f,11,Color.rgb(62,72,66),Paint.Align.CENTER); }
            drawText(c,"iamyansi works quietly in the background",w/2f,h-48,11,Color.rgb(90,105,94),Paint.Align.CENTER); drawText(c,"TAP A CORE",w/2f,h-26,10,Color.rgb(90,105,94),Paint.Align.CENTER);
        }
        @Override public boolean onTouchEvent(MotionEvent e){
            if(e.getActionMasked()==MotionEvent.ACTION_DOWN){dragging=true;lastX=e.getX();lastY=e.getY();return true;}
            if(e.getActionMasked()==MotionEvent.ACTION_MOVE){if(dragging){yaw+=(e.getX()-lastX)*.004f;pitch+=(e.getY()-lastY)*.003f;pitch=Math.max(-.55f,Math.min(.55f,pitch));lastX=e.getX();lastY=e.getY();invalidate();}return true;}
            if(e.getActionMasked()==MotionEvent.ACTION_UP){float dx=e.getX()-lastX,dy=e.getY()-lastY;dragging=false;if(Math.abs(dx)<24&&Math.abs(dy)<24){if(e.getY()<75&&e.getX()>getWidth()-150){showProfile();return true;}float w=getWidth(),h=getHeight(),cx=w*.5f,cy=h*.48f;for(int i=0;i<cores.length;i++){Point q=project(cores[i][0],cores[i][1],cores[i][2],cx,cy,w,h);if(Math.hypot(e.getX()-q.x,e.getY()-q.y)<Math.min(w,h)*.075f){openCore(i);return true;}}}performClick();return true;}return true;
        }
        @Override public boolean performClick(){super.performClick();return true;}
        private void drawCore(Canvas c,float x,float y,float r,int color){p.setColor(Color.argb(22,Color.red(color),Color.green(color),Color.blue(color)));c.drawCircle(x,y,r*1.8f,p);p.setColor(color);c.drawCircle(x,y,r,p);p.setStyle(Paint.Style.STROKE);p.setStrokeWidth(1);p.setColor(Color.argb(100,Color.red(color),Color.green(color),Color.blue(color)));c.drawCircle(x,y,r*1.32f,p);p.setStyle(Paint.Style.FILL);}
        private Point project(float x,float y,float z,float cx,float cy,float w,float h){float cY=(float)Math.cos(yaw),sY=(float)Math.sin(yaw),X=x*cY-z*sY,Z=x*sY+z*cY,cX=(float)Math.cos(pitch),sX=(float)Math.sin(pitch),Y=y*cX-Z*sX,D=1.55f-(y*sX+Z*cX)*.18f,scale=Math.min(w,h)*.72f/D;return new Point(cx+X*scale,cy-Y*scale);}
        private void drawText(Canvas c,String s,float x,float y,float size,int color,Paint.Align a){text.setTextSize(size);text.setColor(color);text.setTextAlign(a);c.drawText(s,x,y,text);}
        final class Point{final float x,y;Point(float x,float y){this.x=x;this.y=y;}}
    }
}
