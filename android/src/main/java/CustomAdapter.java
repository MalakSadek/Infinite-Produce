package malaksadek.infiniteproduce;

import android.content.Context;
import android.content.Intent;
import android.content.SharedPreferences;
import android.graphics.Paint;
import android.util.Log;
import android.view.LayoutInflater;
import android.view.View;
import android.view.ViewGroup;
import android.widget.AdapterView;
import android.widget.ArrayAdapter;
import android.widget.TextView;
import android.widget.ToggleButton;

import androidx.annotation.NonNull;

import com.google.android.gms.tasks.OnCompleteListener;
import com.google.android.gms.tasks.Task;
import com.google.firebase.firestore.DocumentSnapshot;
import com.google.firebase.firestore.FirebaseFirestore;
import com.google.firebase.firestore.QuerySnapshot;

import org.w3c.dom.Text;

import java.util.ArrayList;
import java.util.HashMap;
import java.util.Map;
import java.util.Objects;

public class CustomAdapter extends ArrayAdapter<todo> {

    public CustomAdapter(Context context, ArrayList<todo> c) {
        super(context, 0, c);

    }

    todo t;

    @Override
    public View getView(final int position, View convertView, ViewGroup parent) {

        if (convertView == null) {
            convertView = LayoutInflater.from(getContext()).inflate(R.layout.todo, parent, false);
        }

        final TextView todotext;
        final ToggleButton tb;
        todotext = (TextView) convertView.findViewById(R.id.todotext);
        tb = convertView.findViewById(R.id.toggleButton);

        fillItem(position, todotext, tb);
        tb.setTag(position);
        todotext.setTag(position);

        tb.setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View v) {
                int position = (int) tb.getTag();

                    SharedPreferences sp = getContext(). getSharedPreferences("InfiniteProduce", 0);
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
                                            if(Objects.equals(document.get("Name").toString(), todotext.getText().toString())){
                                                ID2[0] = document.getId();
                                            }
                                        }

                                        if (tb.isChecked()) {
                                            Map<String, Object> state = new HashMap<>();
                                            state.put("State", "On");
                                            db.collection("Users").document(ID).collection("Todos").document(ID2[0]).update(state);

                                            todotext.setPaintFlags(todotext.getPaintFlags() | Paint.STRIKE_THRU_TEXT_FLAG);
                                            tb.setBackgroundColor(getContext().getResources().getColor(R.color.colorAccentG));
                                        }
                                         else {
                                            Map<String, Object> state = new HashMap<>();
                                            state.put("State", "Off");
                                            db.collection("Users").document(ID).collection("Todos").document(ID2[0]).update(state);

                                            todotext.setPaintFlags(todotext.getPaintFlags() & (~Paint.STRIKE_THRU_TEXT_FLAG));
                                            tb.setBackgroundColor(getContext().getResources().getColor(R.color.colorAccentR));
                                        }

                                    } else {
                                        Log.d("", "Error getting documents: ", task.getException());
                                    }
                                }
                            });

            }
        });



        notifyDataSetChanged();
        return convertView;
    }


    void fillItem (int position, TextView todotext, ToggleButton tb) {
        t = getItem(position);
        todotext.setText(t.name);

        if(t.state.equals("On")) {
            tb.setChecked(true);
            todotext.setPaintFlags(todotext.getPaintFlags() | Paint.STRIKE_THRU_TEXT_FLAG);
            tb.setBackgroundColor(getContext().getResources().getColor(R.color.colorAccentG));
        } else {
            tb.setChecked(false);
            todotext.setPaintFlags(todotext.getPaintFlags() & (~Paint.STRIKE_THRU_TEXT_FLAG));
            tb.setBackgroundColor(getContext().getResources().getColor(R.color.colorAccentR));
        }
    }

    void swapOrder(int p) {

        final int position = p;
        SharedPreferences sp = getContext().getSharedPreferences("InfiniteProduce", 0);
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
                                    if(document.get("Order") == String.valueOf(position+1)) {
                                        document.getReference().update(swap1);
                                    }
                                    if(document.get("Order") == "1") {
                                        document.getReference().update(swap2);
                                    }
                                }
                            }

                        } else {
                            Log.d("", "Error getting documents: ", task.getException());
                        }
                    }
                });
    }
}