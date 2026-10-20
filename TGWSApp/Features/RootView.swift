import SwiftUI
import TGWSCore

struct RootView: View {
    var body: some View {
        TabView {
            NavigationStack { HomeView() }
                .tabItem { Label("Главная", systemImage: "house") }
            NavigationStack { DiagnosticsView() }
                .tabItem { Label("Диагностика", systemImage: "waveform.path.ecg") }
            NavigationStack { SettingsView() }
                .tabItem { Label("Настройки", systemImage: "gearshape") }
        }
        .tint(.cyan)
    }
}

private struct HomeView: View {
    @EnvironmentObject private var model: AppModel

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 18) {
                Text("TGWS-iOS")
                    .font(.system(size: 34, weight: .bold, design: .rounded))
                Text("Premium Minimal · iPhone")
                    .foregroundStyle(.secondary)
                VStack(alignment: .leading, spacing: 12) {
                    Label("Протокольное ядро ещё не подключено", systemImage: "wrench.and.screwdriver")
                        .font(.headline)
                    Text("Стартовый проект содержит интерфейс, защищённое хранение параметров и базовые тесты. Он пока НЕ является работающим MTProto-прокси.")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                }
                .padding(18)
                .frame(maxWidth: .infinity, alignment: .leading)
                .background(.white.opacity(0.07), in: RoundedRectangle(cornerRadius: 18))
                VStack(alignment: .leading, spacing: 8) {
                    Text("Статус").font(.headline)
                    Text("Не реализовано").foregroundStyle(.orange)
                    Text("Сначала требуется проверить localhost и фоновые ограничения iOS на физическом iPhone.")
                        .font(.footnote)
                        .foregroundStyle(.secondary)
                }
                .padding(18)
                .frame(maxWidth: .infinity, alignment: .leading)
                .background(.white.opacity(0.05), in: RoundedRectangle(cornerRadius: 18))
            }
            .padding(20)
        }
        .navigationTitle("Главная")
    }
}

private struct DiagnosticsView: View {
    @EnvironmentObject private var model: AppModel

    var body: some View {
        List {
            Section("Состояние") {
                LabeledContent("MTProto listener", value: "Не реализован")
                LabeledContent("Транспорт", value: "Нет активного")
                LabeledContent("Сессии Telegram", value: "Не измеряются")
                LabeledContent("Сборка", value: model.sourceRevision)
            }
            Section("Принцип") {
                Text("Показатели появятся только после фактического подключения ядра. Моковые сессии и выдуманные задержки запрещены.")
                    .foregroundStyle(.secondary)
            }
        }
        .navigationTitle("Диагностика")
    }
}

private struct SettingsView: View {
    @EnvironmentObject private var model: AppModel

    var body: some View {
        Form {
            Section("Локальное соединение") {
                TextField("Порт", text: $model.port)
                    .keyboardType(.numberPad)
                SecureField("Секрет · 32 HEX символа", text: $model.secret)
                    .textInputAutocapitalization(.never)
                    .autocorrectionDisabled()
                TextField("Fake TLS domain (необязательно)", text: $model.fakeTLSDomain)
                    .textInputAutocapitalization(.never)
                    .autocorrectionDisabled()
            }
            Section("Транспорт") {
                Picker("Режим", selection: $model.mode) {
                    ForEach(TransportMode.allCases) { mode in
                        Text(mode.title).tag(mode)
                    }
                }
                SecureField("WSS relay URL (если нужен)", text: $model.relayURL)
                    .textInputAutocapitalization(.never)
                    .autocorrectionDisabled()
            }
            Section {
                Button("Сохранить параметры") { model.saveConfiguration() }
                if !model.feedback.isEmpty {
                    Text(model.feedback)
                        .font(.footnote)
                        .foregroundStyle(.secondary)
                }
            } footer: {
                Text("Секрет и адрес реле хранятся в Keychain. До реализации протокольного ядра кнопки подключения нет.")
            }
        }
        .navigationTitle("Настройки")
    }
}
