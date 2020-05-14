package malaksadek.infiniteproduce;

import androidx.annotation.NonNull;
import androidx.appcompat.app.AppCompatActivity;

import android.content.Intent;
import android.content.SharedPreferences;
import android.graphics.Bitmap;
import android.os.Bundle;
import android.util.Log;
import android.view.View;
import android.widget.Button;
import android.widget.EditText;
import android.widget.Toast;

import com.google.android.gms.tasks.OnCompleteListener;
import com.google.android.gms.tasks.OnFailureListener;
import com.google.android.gms.tasks.OnSuccessListener;
import com.google.android.gms.tasks.Task;
import com.google.firebase.FirebaseApp;
import com.google.firebase.firestore.DocumentSnapshot;
import com.google.firebase.firestore.FirebaseFirestore;
import com.google.firebase.firestore.QuerySnapshot;
import com.google.firebase.storage.FirebaseStorage;
import com.google.firebase.storage.StorageReference;
import com.google.firebase.storage.UploadTask;

import java.io.ByteArrayOutputStream;
import java.util.HashMap;
import java.util.Map;
import java.util.Objects;

public class FirstActivity extends AppCompatActivity {

    Button old, done;
    EditText username;
    SharedPreferences firsttime;
    int unique;

    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        setContentView(R.layout.activity_first);

        if(!checkFirst()) {
            Intent i = new Intent(getApplicationContext(), MainActivity.class);
            i.putExtra("mode", 0);
            startActivity(i);
        } else {
            Setup();

            done.setOnClickListener(new View.OnClickListener() {
                @Override
                public void onClick(View v) {
                    doneButtonPressed();
                }
            });

            old.setOnClickListener(new View.OnClickListener() {
                @Override
                public void onClick(View v) {
                    oldButtonPressed();
                }
            });
        }
    }

    boolean checkFirst() {
        firsttime = getSharedPreferences("InfiniteProduce", 0);
        boolean first = firsttime.getBoolean("First", true);
        return first;
    }

    void Setup() {
        old = findViewById(R.id.oldButton);
        done = findViewById(R.id.doneButton);
        username = findViewById(R.id.usernameBox);
        FirebaseApp.initializeApp(getApplicationContext());
    }

    void doneButtonPressed() {
        unique = 1;
        FirebaseFirestore db = FirebaseFirestore.getInstance();
        db.collection("Users")
                .get()
                .addOnCompleteListener(new OnCompleteListener<QuerySnapshot>() {
                    @Override
                    public void onComplete(@NonNull Task<QuerySnapshot> task) {
                        if (task.isSuccessful()) {
                            for (DocumentSnapshot document : task.getResult()) {
                                for (int i = 0; i < task.getResult().size(); i++) {
                                    if(Objects.equals(document.get("Username").toString(), username.getText().toString())){
                                        unique = 0;
                                    }
                                }

                                if(unique == 0) {
                                    Toast.makeText(getApplicationContext(), "Username is already taken, please try another one!", Toast.LENGTH_LONG).show();
                                } else {
                                    uploadData();
                                    firsttime = getSharedPreferences("InfiniteProduce", 0);
                                    SharedPreferences.Editor editor = firsttime.edit();
                                    editor.putString("Username", username.getText().toString());
                                    editor.putBoolean("First", false);
                                    editor.commit();

                                    Intent i = new Intent(getApplicationContext(), MainActivity.class);
                                    i.putExtra("mode", 0);
                                    startActivity(i);
                                }
                            }
                        } else {
                            Log.d("", "Error getting documents: ", task.getException());
                        }
                    }
                });
    }

    void oldButtonPressed() {
        if(username.getText().toString().isEmpty()) {
            Toast.makeText(getApplicationContext(), "Please enter your old username in the text box and press this button again!", Toast.LENGTH_LONG).show();
        } else {
            firsttime = getSharedPreferences("InfiniteProduce", 0);
            final SharedPreferences.Editor editor = firsttime.edit();
            editor.putString("Username", username.getText().toString());
            editor.putBoolean("First", false);

            FirebaseFirestore db = FirebaseFirestore.getInstance();
            db.collection("Users")
                    .get()
                    .addOnCompleteListener(new OnCompleteListener<QuerySnapshot>() {
                        @Override
                        public void onComplete(@NonNull Task<QuerySnapshot> task) {
                            if (task.isSuccessful()) {
                                for (DocumentSnapshot document : task.getResult()) {
                                    for (int i = 0; i < task.getResult().size(); i++) {
                                        if(Objects.equals(document.get("Username").toString(), username.getText().toString())){
                                            editor.putString("ID", document.getId());
                                            Log.i("ID", document.getId());
                                        }
                                    }

                                    editor.commit();
                                    Intent i = new Intent(getApplicationContext(), MainActivity.class);
                                    i.putExtra("mode", 0);
                                    startActivity(i);
                                }
                            } else {
                                Log.d("", "Error getting documents: ", task.getException());
                            }
                        }
                    });


        }
    }

    void uploadData() {
        todo newtodo = new todo("Sample Todo", "This is just to show you how things look like, feel free to delete it!", "Off", "1");
        FirebaseFirestore db = FirebaseFirestore.getInstance();

        Map<String, Object> data = new HashMap<>();
        Map<String, Object> name = new HashMap<>();
        name.put("Username", username.getText().toString());
        data.put("Name", newtodo.name);
        data.put("Note", newtodo.note);
        data.put("State", newtodo.state);
        data.put("Order", newtodo.order);

        String ID = db.collection("Users").document().getId();
        db.collection("Users").document(ID).set(name);
        firsttime = getSharedPreferences("InfiniteProduce", 0);
        SharedPreferences.Editor editor = firsttime.edit();
        editor.putString("ID", ID);
        editor.commit();


        String ID2 = db.collection("Users").document(ID).collection("Todos").document().getId();

        data.put("ID", ID2);

        db.collection("Users").document(ID).collection("Todos").document(ID2).set(data);

    }
}
