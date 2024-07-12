//
//  CalendarView.swift
//  WanderBoard
//
//  Created by David Jang on 6/14/24.
//

import SwiftUI

struct CalendarView: View {
    @State private var selectedStartDate: Date?
    @State private var selectedEndDate: Date?
    @State private var currentMonth: Date = Date()
    @State private var showingDatePicker = false
    
    private let calendar = Calendar.current
    private let dateFormatter: DateFormatter
    private let displayDateFormatter: DateFormatter
    
    var onDatesSelected: ((Date, Date) -> Void)?
    @Environment(\.presentationMode) var presentationMode
    
    init(onDatesSelected: ((Date, Date) -> Void)? = nil) {
        self.onDatesSelected = onDatesSelected
        dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "MMMM yyyy"
        displayDateFormatter = DateFormatter()
        displayDateFormatter.dateFormat = "MM.dd EEEE"
    }
    
    var body: some View {
        VStack {
            HStack {
                Text(dateFormatter.string(from: currentMonth))
                    .font(.headline)
                Spacer()
                Button(action: { showingDatePicker.toggle() }) {
                    Image(systemName: showingDatePicker ? "chevron.down" : "chevron.right")
                        .foregroundColor(.black)
                }
            }
            .padding()
            
            if showingDatePicker {
                DatePicker("", selection: $currentMonth, displayedComponents: [.date])
                    .datePickerStyle(WheelDatePickerStyle())
                    .labelsHidden()
                    .onChange(of: currentMonth) { _ in
                        showingDatePicker = false
                    }
            } else {
                HStack(spacing: -28) {
                    ForEach(["SUN", "MON", "TUE", "WED", "THU", "FRI", "SAT"], id: \.self) { day in
                        Text(day)
                            .frame(maxWidth: .infinity)
                            .font(.caption2)
                            .foregroundColor(Color("darkgray"))
                    }
                }
                .padding(.bottom, 5)
                
                let days = generateDaysInMonth(for: currentMonth)
                LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 7), spacing: 15) {
                    ForEach(Array(days.enumerated()), id: \.offset) { index, date in
                        Text(date != nil ? "\(calendar.component(.day, from: date!))" : "")
                            .frame(width: 30, height: 30)
                            .background(getBackgroundColor(for: date))
                            .foregroundColor(getTextColor(for: date))
                            .cornerRadius(15)
                            .onTapGesture {
                                if let date = date {
                                    if selectedStartDate == nil || (selectedStartDate != nil && selectedEndDate != nil) {
                                        selectedStartDate = date
                                        selectedEndDate = nil
                                    } else if let startDate = selectedStartDate, date >= startDate {
                                        selectedEndDate = date
                                    }
                                }
                            }
                    }
                }
                .padding()
                .gesture(DragGesture().onEnded { value in
                    if value.translation.width < 0 {
                        currentMonth = calendar.date(byAdding: .month, value: 1, to: currentMonth) ?? currentMonth
                    } else if value.translation.width > 0 {
                        currentMonth = calendar.date(byAdding: .month, value: -1, to: currentMonth) ?? currentMonth
                    }
                })
            }
            Spacer()
            
            if let startDate = selectedStartDate, let endDate = selectedEndDate {
                HStack {
                    Text("\(displayDateFormatter.string(from: startDate))")
                    Text("~")
                    Text("\(displayDateFormatter.string(from: endDate))")
                    Text("(\(calculateDaysBetween(start: startDate, end: endDate)))")
                        .foregroundStyle(.darkgray)

                }
            } else if let startDate = selectedStartDate {
                HStack {
                    Text("\(displayDateFormatter.string(from: startDate))")
                    Text("~")
                    Text("")
                }
            }
            
            Spacer()
            
            Button(action: {
                if let startDate = selectedStartDate, let endDate = selectedEndDate {
                    onDatesSelected?(startDate, endDate) // 선택 버튼을 눌렀을 때 클로저 호출
                    presentationMode.wrappedValue.dismiss() // 캘린더 뷰 닫기
                }
            }) {
                Text("선택")
                    .frame(maxWidth: .infinity, maxHeight: 50)
                    .background(isSelectionComplete() ? Color.font : Color("PageCtrlUnselectedText"))
                    .foregroundColor(Color("textColor"))
                    .cornerRadius(10)
            }
            .disabled(!isSelectionComplete())
            .padding(.horizontal)
        }
        .padding()
        .onChange(of: showingDatePicker) { _ in
            if !showingDatePicker {
                // DatePicker를 숨길 때 캘린더를 업데이트
                currentMonth = calendar.date(from: DateComponents(year: calendar.component(.year, from: currentMonth), month: calendar.component(.month, from: currentMonth))) ?? Date()
            }
        }
    }
    
    private func generateDaysInMonth(for date: Date) -> [Date?] {
        guard let monthInterval = calendar.dateInterval(of: .month, for: date),
              let _ = calendar.dateInterval(of: .weekOfMonth, for: monthInterval.start) else {
            return []
        }
        
        let daysInMonth = calendar.range(of: .day, in: .month, for: date)!.count
        let firstDayOfMonth = calendar.date(from: calendar.dateComponents([.year, .month], from: monthInterval.start))!
        let firstWeekday = calendar.component(.weekday, from: firstDayOfMonth)
        
        var days: [Date?] = []
        for dayOffset in 0..<(daysInMonth + firstWeekday - 1) {
            if dayOffset < firstWeekday - 1 {
                days.append(nil)
            } else {
                let day = dayOffset - (firstWeekday - 2)
                days.append(calendar.date(byAdding: .day, value: day - 1, to: firstDayOfMonth))
            }
        }
        return days
    }
    
    private func getBackgroundColor(for date: Date?) -> Color {
        guard let date = date else { return Color.clear }
        
        if let startDate = selectedStartDate, let endDate = selectedEndDate {
            if date >= startDate && date <= endDate {
                return date == startDate || date == endDate ? Color.black : Color("babygray")
            }
        } else if let startDate = selectedStartDate {
            if date == startDate {
                return Color.black
            }
        }
        
        return Color.clear
    }
    
    private func getTextColor(for date: Date?) -> Color {
        guard let date = date else { return Color.clear }
        
        if let startDate = selectedStartDate {
            if date < startDate {
                return Color.gray
            }
        }
        
        if let startDate = selectedStartDate, let endDate = selectedEndDate {
            if date == startDate || date == endDate {
                return Color.white
            } else if date > startDate && date < endDate {
                return Color.black
            }
        } else if let startDate = selectedStartDate {
            if date == startDate {
                return Color.white
            }
        }
        
        return Color.primary
    }
    
    private func isSelectionComplete() -> Bool {
        return selectedStartDate != nil && selectedEndDate != nil
    }
    
    private func calculateDaysBetween(start: Date, end: Date) -> String {
        let components = calendar.dateComponents([.day], from: start, to: end)
        let dayCount = components.day ?? 0
        return dayCount == 0 ? "1 Day" : "\(dayCount + 1) Days"
    }
}

struct CalendarView_Previews: PreviewProvider {
    static var previews: some View {
        CalendarView()
    }
}
