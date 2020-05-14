package malaksadek.infiniteproduce;

import android.Manifest;
import android.app.Activity;
import android.app.AlertDialog;
import android.app.Dialog;
import android.app.DialogFragment;
import android.content.DialogInterface;
import android.content.Intent;
import android.content.SharedPreferences;
import android.content.pm.PackageManager;
import android.net.Uri;
import android.os.Build;
import android.os.Bundle;
import android.os.Environment;
import android.provider.MediaStore;
import android.util.Log;
import android.view.View;
import android.view.Window;
import android.widget.Button;
import android.widget.TextView;

import androidx.annotation.NonNull;
import androidx.annotation.RequiresApi;
import androidx.core.app.ActivityCompat;
import androidx.core.content.ContextCompat;
import androidx.core.content.FileProvider;

import com.google.android.gms.tasks.OnCompleteListener;
import com.google.android.gms.tasks.Task;
import com.google.firebase.firestore.DocumentSnapshot;
import com.google.firebase.firestore.FirebaseFirestore;
import com.google.firebase.firestore.QuerySnapshot;

import java.io.File;
import java.io.IOException;
import java.text.SimpleDateFormat;
import java.util.Collections;
import java.util.Comparator;
import java.util.Date;
import java.util.HashMap;
import java.util.Map;

public class OptionsDialogFragment extends Dialog implements android.view.View.OnClickListener {


    public Activity a;
    Button edit, notes, delete;
    TextView title;
    int selectedIndex;

    public OptionsDialogFragment(Activity a, String todo, int p) {
        super(a);
        this.a = a;
        requestWindowFeature(Window.FEATURE_ACTIVITY_TRANSITIONS);
        setContentView(R.layout.todo_dialog);
        edit = findViewById(R.id.editbutton);
        notes = findViewById(R.id.notesbutton);
        delete = findViewById(R.id.deletebutton);
        title = findViewById(R.id.todotitle);
        title.setText(todo);
        selectedIndex = p;
    }

    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        edit.setOnClickListener(this);
        notes.setOnClickListener(this);
        delete.setOnClickListener(this);
    }

    @Override
    public void onClick(View v) {
        Intent i;
        switch (v.getId()) {
            case R.id.editbutton:
                i = new Intent(getContext(), MainActivity.class);
                i.putExtra("mode", 1);
                i.putExtra("selectedIndex", selectedIndex);
                i.putExtra("selectedTodo", title.getText().toString());
                getContext().startActivity(i);
                break;

            case R.id.notesbutton:
                i = new Intent(getContext(), ActivityNote.class);
                i.putExtra("selectedIndex", selectedIndex);
                i.putExtra("title", title.getText().toString());
                getContext().startActivity(i);
                break;

            case R.id.deletebutton:

                SharedPreferences sp = getContext().getSharedPreferences("InfiniteProduce", 0);
                String ID = sp.getString("ID", "");


                FirebaseFirestore db = FirebaseFirestore.getInstance();
                db.collection("Users").document(ID).collection("Todos")
                        .get()
                        .addOnCompleteListener(new OnCompleteListener<QuerySnapshot>() {
                            @Override
                            public void onComplete(@NonNull Task<QuerySnapshot> task) {
                                if (task.isSuccessful()) {

                                    for (DocumentSnapshot document : task.getResult()) {
                                        if (document.exists()) {
                                            if (document.get("Name").toString().equals(title.getText().toString())) {
                                                document.getReference().delete();
                                            }

                                            if(Integer.valueOf(document.get("Order").toString()) > selectedIndex) {
                                                final Map<String, Object> data = new HashMap<>();
                                                data.put("Order", String.valueOf(Integer.valueOf(document.get("Order").toString())-1));
                                                document.getReference().update(data);
                                            }
                                        }
                                    }

                                    Intent in = new Intent(getContext(), MainActivity.class);
                                    in.putExtra("mode", 0);
                                    getContext().startActivity(in);

                                } else {
                                    Log.d("", "Error getting documents: ", task.getException());
                                }
                            }
                        });

                break;
        }
        dismiss();
    }
}

