package malaksadek.infiniteproduce;

import android.content.Intent;
import android.content.SharedPreferences;
import android.os.Bundle;
import android.util.Log;
import android.view.View;
import android.view.Window;
import android.view.WindowManager;
import android.widget.AdapterView;
import android.widget.Button;
import android.widget.EditText;
import android.widget.ImageView;
import android.widget.ListView;
import android.widget.TextView;
import android.widget.Toast;

import androidx.annotation.NonNull;
import androidx.appcompat.app.AppCompatActivity;

import com.google.android.gms.tasks.OnCompleteListener;
import com.google.android.gms.tasks.Task;
import com.google.firebase.firestore.DocumentSnapshot;
import com.google.firebase.firestore.FirebaseFirestore;
import com.google.firebase.firestore.QuerySnapshot;

import java.util.ArrayList;
import java.util.Collections;
import java.util.Comparator;
import java.util.HashMap;
import java.util.Map;

public class MainActivity extends AppCompatActivity {

    Button cancel, newtodo, addtodo, inspiration;
    TextView prompt, donetext;
    EditText newtodotext;
    ImageView dimmer;
    ArrayList<todo> arrayOfTodos;
    ListView todos;
    int selectedIndex = 0;
    int mode = 0;
    int totalTodos = 0;



    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        requestWindowFeature(Window.FEATURE_NO_TITLE);
        getWindow().setFlags(WindowManager.LayoutParams.FLAG_FULLSCREEN, WindowManager.LayoutParams.FLAG_FULLSCREEN);
        setContentView(R.layout.activity_main);
        getWindow().setSoftInputMode(WindowManager.LayoutParams.SOFT_INPUT_ADJUST_PAN);

        SharedPreferences sp = getSharedPreferences("InfiniteProduce", 0);

        if (sp.getBoolean("FirstMain", true)) {
            Toast.makeText(getApplicationContext(), "Short pressing a todo puts it at the top of the list, long pressing a todo opens the options menu for it.", Toast.LENGTH_LONG).show();
            SharedPreferences.Editor editor = sp.edit();
            editor.putBoolean("FirstMain", false);
            editor.commit();
        }

        Setup();

        if (mode == 0) {
            donetext.setVisibility(View.INVISIBLE);
            newtodotext.setVisibility(View.INVISIBLE);
            addtodo.setVisibility(View.INVISIBLE);
            prompt.setVisibility(View.INVISIBLE);
            cancel.setVisibility(View.INVISIBLE);
            fetchData();

        } else {
            newtodotext.setText(getIntent().getStringExtra("selectedTodo"));
            selectedIndex = getIntent().getIntExtra("selectedIndex", 0);
            newtodotext.setVisibility(View.VISIBLE);
            donetext.setVisibility(View.INVISIBLE);
            addtodo.setVisibility(View.VISIBLE);
            dimmer.setVisibility(View.VISIBLE);
            prompt.setVisibility(View.VISIBLE);
            cancel.setVisibility(View.VISIBLE);
            todos.setVisibility(View.INVISIBLE);
            fetchData();
        }

        todos.setOnItemLongClickListener(new AdapterView.OnItemLongClickListener() {
            @Override
            public boolean onItemLongClick(AdapterView<?> parent, View view, int position, long id) {
                OptionsDialogFragment odf = new OptionsDialogFragment(MainActivity.this, arrayOfTodos.get(position).name, position);
                odf.show();
                return true;
            }
        });

        todos.setOnItemClickListener(new AdapterView.OnItemClickListener() {
            @Override
            public void onItemClick(AdapterView<?> parent, View view, int position, long id) {
                swapOrder(position);
            }
        });

        newtodo.setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View v) {
                newTodo();
            }
        });

        inspiration.setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View v) {
                Intent i = new Intent(getApplicationContext(), ActivityImage.class);
                startActivity(i);
            }
        });

        cancel.setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View v) {
                cancel();
                mode = 0;
            }
        });

        addtodo.setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View v) {
                addTodo();
                mode = 0;
            }
        });


    }

    void Setup() {
        mode = getIntent().getIntExtra("mode", 0);

        cancel = findViewById(R.id.cancelbutton);
        newtodo = findViewById(R.id.newtodobutton);
        addtodo = findViewById(R.id.addtodobutton);
        inspiration = findViewById(R.id.inspirationbutton);
        prompt = findViewById(R.id.newtodoprompt);
        newtodotext = findViewById(R.id.newtodotext);
        dimmer = findViewById(R.id.dimmer);
        donetext = findViewById(R.id.donetext);
        todos = findViewById(R.id.todos);
        arrayOfTodos = new ArrayList<todo>(50);
    }

    void fetchData() {

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
                                    final todo t = new todo("a","b","c","d");
                                    t.name = document.get("Name").toString();
                                    t.note = document.get("Note").toString();
                                    t.state = document.get("State").toString();
                                    t.order = document.get("Order").toString();
                                    arrayOfTodos.add(i, t);
                                    totalTodos = totalTodos + 1;
                                    i++;
                                }
                            }

                            Collections.sort(arrayOfTodos, new Comparator<todo>() {
                                public int compare(todo v1, todo v2) {
                                    return v1.order.compareTo(v2.order);
                                }
                            });


                            CustomAdapter CA = new CustomAdapter(getApplicationContext(), arrayOfTodos);
                            todos.setAdapter(CA);
                            dimmer.setVisibility(View.INVISIBLE);

                            if(arrayOfTodos.size() > 0) {
                                donetext.setVisibility(View.INVISIBLE);
                            } else {
                                donetext.setVisibility(View.VISIBLE);
                            }

                        } else {
                            Log.d("", "Error getting documents: ", task.getException());
                        }
                    }
                });
    }

    void swapOrder(int p) {

        final int position = p;
        SharedPreferences sp = getSharedPreferences("InfiniteProduce", 0);
        String ID = sp.getString("ID", "");

        final Map<String, Object> swap1 = new HashMap<>();
        swap1.put("Order", "1");
        final Map<String, Object> swap2 = new HashMap<>();
        swap2.put("Order", String.valueOf(p+1));

        FirebaseFirestore db = FirebaseFirestore.getInstance();
        db.collection("Users").document(ID).collection("Todos")
                .get()
                .addOnCompleteListener(new OnCompleteListener<QuerySnapshot>() {
                    @Override
                    public void onComplete(@NonNull Task<QuerySnapshot> task) {
                        if (task.isSuccessful()) {
                            for (DocumentSnapshot document : task.getResult()) {
                                if (document.exists()) {
                                    Log.i("position", String.valueOf(position+1));
                                    Log.i("order", String.valueOf(document.get("Order")));

                                    if(String.valueOf(document.get("Order")).equals(String.valueOf(position + 1))) {
                                        Log.i("swapee", String.valueOf(document.get("Order")));
                                        document.getReference().update(swap1);
                                    }
                                    if(String.valueOf(document.get("Order")).equals("1")) {
                                        Log.i("swaper", String.valueOf(document.get("Order")));
                                        document.getReference().update(swap2);
                                    }
                                }
                            }

                            arrayOfTodos.clear();
                            fetchData();

                        } else {
                            Log.d("", "Error getting documents: ", task.getException());
                        }
                    }
                });


    }

    void cancel() {
        newtodotext.setVisibility(View.INVISIBLE);
        dimmer.setVisibility(View.INVISIBLE);
        prompt.setVisibility(View.INVISIBLE);
        cancel.setVisibility(View.INVISIBLE);
        addtodo.setVisibility(View.INVISIBLE);
        todos.setVisibility(View.VISIBLE);
        arrayOfTodos.clear();
        fetchData();
        newtodotext.setText("");
    }

    void addTodo() {

        if (newtodotext.getText().toString().isEmpty()) {
            Toast.makeText(getApplicationContext(), "Make sure you enter something to do first!", Toast.LENGTH_LONG).show();
        } else {
            uploadData();
            newtodotext.setVisibility(View.INVISIBLE);
            dimmer.setVisibility(View.INVISIBLE);
            prompt.setVisibility(View.INVISIBLE);
            cancel.setVisibility(View.INVISIBLE);
            addtodo.setVisibility(View.INVISIBLE);
            todos.setVisibility(View.VISIBLE);
            newtodotext.setText("");
        }
    }

    void newTodo() {
        newtodo.setVisibility(View.VISIBLE);
        newtodotext.setVisibility(View.VISIBLE);
        dimmer.setVisibility(View.VISIBLE);
        prompt.setVisibility(View.VISIBLE);
        cancel.setVisibility(View.VISIBLE);
        addtodo.setVisibility(View.VISIBLE);
        todos.setVisibility(View.INVISIBLE);
    }

    void uploadData() {

        if (mode == 0) {
            todo newtodo = new todo(newtodotext.getText().toString(), "No notes yet!", "Off", String.valueOf(totalTodos + 1));
            FirebaseFirestore db = FirebaseFirestore.getInstance();

            Map<String, Object> data = new HashMap<>();
            data.put("Name", newtodo.name);
            data.put("Note", newtodo.note);
            data.put("State", newtodo.state);
            data.put("Order", newtodo.order);

            SharedPreferences sp = getSharedPreferences("InfiniteProduce", 0);
            String ID = sp.getString("ID", "");

            String ID2 = db.collection("Users").document(ID).collection("Todos").document().getId();

            data.put("ID", ID2);

            db.collection("Users").document(ID).collection("Todos").document(ID2).set(data);
        } else if (mode == 1) {

            SharedPreferences sp = getSharedPreferences("InfiniteProduce", 0);
            String ID = sp.getString("ID", "");

            final Map<String, Object> data = new HashMap<>();
            data.put("Name", newtodotext.getText().toString());

            FirebaseFirestore db = FirebaseFirestore.getInstance();
            db.collection("Users").document(ID).collection("Todos")
                    .get()
                    .addOnCompleteListener(new OnCompleteListener<QuerySnapshot>() {
                        @Override
                        public void onComplete(@NonNull Task<QuerySnapshot> task) {
                            if (task.isSuccessful()) {
                                for (DocumentSnapshot document : task.getResult()) {
                                    if (document.exists()) {
                                        if(String.valueOf(document.get("Name")).equals(getIntent().getStringExtra("selectedTodo"))) {
                                            document.getReference().update(data);
                                        }
                                    }
                                }

                                arrayOfTodos.clear();
                                fetchData();

                            } else {
                                Log.d("", "Error getting documents: ", task.getException());
                            }
                        }
                    });
        }
    }
}