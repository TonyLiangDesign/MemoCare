import SwiftUI
import SwiftData

/// Create medication plan form
struct AddPlanView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss

    @State private var medicationName = ""
    @State private var scheduledTime = Date()
    @State private var windowMinutes = 30
    @State private var repeatDaily = true

    var body: some View {
        NavigationStack {
            Form {
                Section(String(localized: "药物信息")) {
                    TextField(String(localized: "药物名称"), text: $medicationName)
                }

                Section(String(localized: "时间设置")) {
                    DatePicker(String(localized: "服药时间"), selection: $scheduledTime, displayedComponents: .hourAndMinute)

                    Stepper(String(localized: "允许提前 \(windowMinutes) 分钟"), value: $windowMinutes, in: 5...120, step: 5)

                    Toggle(String(localized: "每日重复"), isOn: $repeatDaily)
                }
            }
            .navigationTitle(String(localized: "新增计划"))
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button(String(localized: "取消")) { dismiss() }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button(String(localized: "保存")) { save() }
                        .disabled(medicationName.isEmpty)
                }
            }
        }
    }

    private func save() {
        let plan = MedicationPlan(
            medicationName: medicationName,
            scheduledTime: scheduledTime,
            windowMinutes: windowMinutes,
            repeatDaily: repeatDaily
        )
        modelContext.insert(plan)

        let startTime = scheduledTime.addingTimeInterval(
            -Double(windowMinutes) * 60
        )
        let foresight = Foresight(
            content: String(localized: "服用 \(medicationName)"),
            evidence: String(localized: "照护者创建的用药计划"),
            startTime: startTime,
            endTime: scheduledTime,
            parentType: "medication_plan",
            parentID: plan.planID
        )
        modelContext.insert(foresight)

        try? modelContext.save()
        dismiss()
    }
}