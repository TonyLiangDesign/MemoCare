import SwiftUI
import SwiftData

struct RecommendationDetailView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var modelContext

    let recommendation: CaregiverRecommendation
    @State private var notes = ""

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 20) {
                    titleSection
                    contextSection
                    suggestionSection
                    evidenceSection
                    notesSection
                }
                .padding()
            }
            .navigationTitle(String(localized: "建议详情"))
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button(String(localized: "关闭")) { dismiss() }
                }
                ToolbarItem(placement: .primaryAction) {
                    Menu(String(localized: "操作"), systemImage: "ellipsis.circle") {
                        Button(String(localized: "接受"), systemImage: "checkmark") { accept() }
                        Button(String(localized: "忽略"), systemImage: "xmark") { dismissRec() }
                    }
                }
            }
        }
    }

    private var titleSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(recommendation.title)
                .font(.title2.bold())
            HStack {
                CapsuleBadge(value: recommendation.priority)
                confidenceBadge
                Spacer()
            }
        }
    }

    private var contextSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(String(localized: "情况说明"))
                .font(.headline)
            Text(recommendation.context)
                .font(.body)
                .foregroundStyle(.secondary)
        }
        .padding()
        .background(.quaternary, in: RoundedRectangle(cornerRadius: 12))
    }

    private var suggestionSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(String(localized: "建议措施"))
                .font(.headline)
            Text(recommendation.suggestion)
                .font(.body)
        }
        .padding()
        .background(.blue.opacity(0.1), in: RoundedRectangle(cornerRadius: 12))
    }

    private var evidenceSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(String(localized: "相关证据"))
                .font(.headline)
            Text(String(localized: "\(recommendation.evidenceIDs.count) 条记录"))
                .font(.subheadline)
                .foregroundStyle(.secondary)
        }
    }

    private var notesSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(String(localized: "备注"))
                .font(.headline)
            TextField(String(localized: "添加备注..."), text: $notes, axis: .vertical)
                .textFieldStyle(.roundedBorder)
                .lineLimit(3...6)
        }
    }

    private var confidenceBadge: some View {
        Text(String(localized: "置信度 \(Int(recommendation.confidence * 100))%"))
            .font(.caption)
            .foregroundStyle(.secondary)
    }

    private func accept() {
        recommendation.status = .accepted
        recommendation.acceptedAt = Date()
        recommendation.caregiverNotes = notes.isEmpty ? nil : notes
        try? modelContext.save()
        dismiss()
    }

    private func dismissRec() {
        recommendation.status = .dismissed
        recommendation.dismissedAt = Date()
        recommendation.caregiverNotes = notes.isEmpty ? nil : notes
        try? modelContext.save()
        dismiss()
    }
}
