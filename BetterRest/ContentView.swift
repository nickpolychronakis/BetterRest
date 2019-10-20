//
//  ContentView.swift
//  BetterRest
//
//  Created by NICK POLYCHRONAKIS on 19/10/19.
//  Copyright © 2019 NICK POLYCHRONAKIS. All rights reserved.
//

import SwiftUI

struct ContentView: View {
    
    // MARK: - Binding properties
    @State private var wakeUp = defaultWakeTime
    @State private var sleepAmount = 8.0
    @State private var coffeeAmount = 1
    
    // MARK: - View body
    var body: some View {
        NavigationView {
            Form {
                // MARK: WakeUp time
                Section(header: Text("When do you want to wake up?")) {
                    DatePicker("Please enter a time", selection: $wakeUp, displayedComponents: .hourAndMinute)
                        .labelsHidden()
                        .datePickerStyle(WheelDatePickerStyle())
                }
                // MARK: Desired sleep
                Section(header: Text("Desired amount of sleep")) {
                    Stepper(value: $sleepAmount, in: 4...12) {
                        Text("\(sleepAmount, specifier: "%g") hours")
                    }
                }
                // MARK: Coffee intake
                Section(header: Text("Daily coffee intake")) {
                    // Stepper version
                    Stepper(value: $coffeeAmount, in: 1...20) {
                        if coffeeAmount == 1 {
                            Text("1 cup")
                        } else {
                            Text("\(coffeeAmount) cups")
                        }
                    }
                    // Picker version (I didn't liked it so I commented it
//                    Picker(selection: $coffeeAmount, label: coffeeAmount == 1 ? Text("1 cup") : Text("\(coffeeAmount) cups")) {
//                        ForEach(1...20, id: \.self) {
//                            Text("\($0)")
//                        }
//                    }
                }
                // MARK: Recomended bed time
                Section(header: Text("Recomended bedtime:")) {
                    Text(calculateBedtime())
                        .font(.title)
                }
            }
            .navigationBarTitle("BetterRest")
        }
    }
    
    
    // MARK: - Default wake time
    /// The default date time to be used with datePicker
    static var defaultWakeTime: Date {
        var components = DateComponents()
        components.hour = 7
        components.minute = 0
        return Calendar.current.date(from: components) ?? Date()
    }
    
    
    // MARK: - Bed time (ML)
    /// Calculates and shows the best time to go to bed, based on ML data NOT PURE
    func calculateBedtime() -> String {
        // Initializing ML
        let model = SleepCalculator()
        // Converting wakeUp time to seconds
        let components = Calendar.current.dateComponents([.hour,.minute], from: wakeUp)
        let hour = (components.hour ?? 0) * 60 * 60
        let minute = (components.minute ?? 0) * 60
        
        do {
            // Predictions of ML
            let prediction = try model.prediction(wake: Double(hour + minute), estimatedSleep: sleepAmount, coffee: Double(coffeeAmount))
            // Finding sleep time
            let sleepTime = wakeUp - prediction.actualSleep
            // Formatter
            let formatter = DateFormatter()
            formatter.timeStyle = .short
            
            return formatter.string(from: sleepTime)
        } catch {
            return "Error: Your machine is on vecations"
        }
    }
    
    
}




struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
