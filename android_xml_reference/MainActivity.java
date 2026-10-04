package com.example.currencyconverter;

import android.os.Bundle;
import android.widget.Button;
import android.widget.EditText;
import android.widget.TextView;
import android.widget.Toast;
import androidx.appcompat.app.AppCompatActivity;

/**
 * ANDROID JAVA REFERENCE (Lecture Comparison)
 * Look at how Flutter simplifies this using StatefulWidget & setState()!
 */
public class MainActivity extends AppCompatActivity {

    private EditText etAmount;
    private Button btnConvert;
    private TextView tvResult;
    private static final double EXCHANGE_RATE = 278.50; // USD to PKR

    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        setContentView(R.layout.activity_main); // Inflates the XML layout

        // 1. Finding Views from XML
        etAmount = findViewById(R.id.etAmount);
        btnConvert = findViewById(R.id.btnConvert);
        tvResult = findViewById(R.id.tvResult);

        // 2. Setting Event Listener
        btnConvert.setOnClickListener(v -> {
            String input = etAmount.getText().toString().trim();
            if (!input.isEmpty()) {
                try {
                    double amount = Double.parseDouble(input);
                    double result = amount * EXCHANGE_RATE;
                    tvResult.setText(String.format("PKR %.2f", result));
                } catch (NumberFormatException e) {
                    Toast.makeText(MainActivity.this, "Invalid number entered", Toast.LENGTH_SHORT).show();
                }
            } else {
                Toast.makeText(MainActivity.this, "Please enter an amount", Toast.LENGTH_SHORT).show();
            }
        });
    }
}
