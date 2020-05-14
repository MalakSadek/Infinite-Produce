package malaksadek.infiniteproduce;

import android.content.SharedPreferences;
import android.graphics.Paint;
import android.os.Bundle;
import android.util.Log;
import android.view.View;
import android.widget.Button;
import android.widget.EditText;
import android.widget.TextView;
import android.widget.Toast;

import androidx.annotation.NonNull;
import androidx.appcompat.app.AppCompatActivity;

import com.google.android.gms.tasks.OnCompleteListener;
import com.google.android.gms.tasks.Task;
import com.google.firebase.firestore.DocumentSnapshot;
import com.google.firebase.firestore.FirebaseFirestore;
import com.google.firebase.firestore.QuerySnapshot;

import java.util.Collections;
import java.util.Comparator;
import java.util.HashMap;
import java.util.Map;
import java.util.Objects;

public class ActivityNote extends AppCompatActivity {

    int selectedIndex;
    String title;
    TextView titletext;
    EditText notes;
    Button save;
    Boolean first;

    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        setContentView(R.layout.activity_note);

        Setup();

        save.setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View v) {
                saveNotes();
            }
        });

        fetchNotes();
    }


    void Setup() {
        selectedIndex = getIntent().getIntExtra("selectedIndex", 0);
        title = getIntent().getStringExtra("title");
        titletext = findViewById(R.id.title);
        notes = findViewById(R.id.notes);
        titletext.setText(title);
        save = findViewById(R.id.save);
        SharedPreferences sp = getSharedPreferences("InfiniteProduce", 0);
        first = sp.getBoolean("FirstNote", true);

        if (first) {
            Toast.makeText(getApplicationContext(), "Please press save whenever you update your notes or else you won't find the update next time!", Toast.LENGTH_LONG).show();
        }
    }

    void fetchNotes() {

        SharedPreferences sp = getSharedPreferences("InfiniteProduce", 0);
        String ID = sp.getString("ID", "");
        FirebaseFirestore db = FirebaseFirestore.getInstance();
        db.collection("Users").document(ID).collection("Todos")
                .get()
                .addOnCompleteListener(new OnCompleteListener<QuerySnapshot>() {
                    @Override
                    public void onComplete(@NonNull Task<QuerySnapshot> task) {
                        if (task.isSuccessful()) {
                            int i = 0;
                            for (DocumentSnapshot document : task.getResult()) {
                                if (document.exists()) {
                                    if (Objects.equals(document.get("Name").toString(), title)) {
                                        notes.setText(document.get("Note").toString());
                                    }
                                }
                            }


                        } else {
                            Log.d("", "Error getting documents: ", task.getException());
                        }
                    }
                });
    }

    void saveNotes() {
        SharedPreferences sp = getSharedPreferences("InfiniteProduce", 0);
        final String ID = sp.getString("ID", "");
        final String[] ID2 = new String[1];
        final FirebaseFirestore db = FirebaseFirestore.getInstance();
        db.collection("Users").document(ID).collection("Todos")
                .get()
                .addOnCompleteListener(new OnCompleteListener<QuerySnapshot>() {
                    @Override
                    public void onComplete(@NonNull Task<QuerySnapshot> task) {
                        if (task.isSuccessful()) {
                            for (DocumentSnapshot document : task.getResult()) {
                                if (Objects.equals(document.get("Name").toString(), title)) {
                                    ID2[0] = document.getId();
                                }
                            }


                            Map<String, Object> note = new HashMap<>();
                            note.put("Note", notes.getText().toString());
                            db.collection("Users").document(ID).collection("Todos").document(ID2[0]).update(note);
                            Toast.makeText(getApplicationContext(), "Note saved! Feel free to leave this page now.", Toast.LENGTH_LONG).show();

                            SharedPreferences sp = getSharedPreferences("InfiniteProduce", 0);
                            SharedPreferences.Editor editor = sp.edit();
                            editor.putBoolean("FirstNote", false);
                            editor.commit();

                        } else {
                            Log.d("", "Error getting documents: ", task.getException());
                        }
                    }
                });

    }
}