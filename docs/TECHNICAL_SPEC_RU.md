# Техническое задание — TGWS-iOS

Версия документа: 1.0 / 20.10.2026  
Инициатор: Makarov Lab's 3.0™  
Базовый проект: `Kust3r3nk0/TGWS-Android` (0.4.0 Premium Minimal)  
Протокольный upstream: `Flowseal/tg-ws-proxy` v1.11.2 (зафиксировать точные SHA)  
Целевое устройство: **только iPhone**  
Язык: **Swift 6**, UI — **SwiftUI**, Сборка — Xcode / XcodeGen.  
Первоначальный minimum: **iOS 17.0** (пересмотреть только по итогам необходимости API/тестов).

## 1. Цель продукта

Нативное iPhone-приложение **TGWS-iOS** — независимый порт TGWS-Android. Его назначение: поддерживать MTProto-совместимый локальный Telegram-прокси на `127.0.0.1`, который направляет протокольный трафик через проверенные WSS/TCP/совместимые реле, насколько это допускается iOS. Приложение не объявляется VPN и не должно изменять системную маршрутизацию без отдельного технического и продуктового решения. **Ключевой риск:** фоновые ограничения iOS могут сделать требуемый локальный сценарий непригодным. Решение о полном порте — после Gate F0 на физическом iPhone.

## 2. Функциональные требования

### 2.1 Telegram / MTProto

- Локальный listener: только loopback (`127.0.0.1`), порт по умолчанию `1443`, явный запуск/остановка пользователем.
- MTProto Obfuscated2 и Padded Intermediate, поддержка семантики `dd` / `ee` Fake TLS по эталонной реализации; не подменять реальный TLS фиктивным сертификатом.
- Отделять состояния: STOPPED / STARTING / LISTENING / ACTIVE / STOPPING / ERROR. `ACTIVE` — только при подтверждённом валидном клиенте и работоспособном внешнем транспорте.
- Генерация Telegram-ссылки в существующем Android-формате; открытие/копирование только явным действием пользователя и после подтверждения, что локальный listener действительно работает.
- Обработка одновременных сессий, handshake 64 байта, DC 1–5 и 203, media DC, AES-CTR и независимые cipher-state.
- Границы памяти/очередей/таймаутов не слабее текущего Android контрактного уровня; базовый максимум одновременных сессий — 8.

### 2.2 Транспорты

Режимы, подлежащие переносy:

1. **DIRECT** — WSS Telegram и TCP fallback согласно протокольным правилам Android; отсутствие доступного маршрута должно быть честной ошибкой.
2. **RELAY_ONLY** — только пользовательский WSS endpoint. Никакого автоматического обхода реле через direct.
3. **AUTO_CLOUDFLARE** — список пользовательских Worker URL и совместимых CF Proxy-доменов, ограниченный перебор кандидатов и TCP fallback в том порядке, который подтверждён Android-кодом.

Сохранить ограничения: максимум 8 Worker URL и 8 доменов, до двух каждого вида на один поиск маршрута, лимит 4 non-TCP + TCP попыток, приблизительные сроки/бюджеты по Android (`8 s` на попытку и `40 s` общего setup для Auto-CF), backoff 1–30 s. Сверить все реальные значения с актуальным исходником перед кодированием. Никаких скрытых/публичных аккаунтов или endpoint по умолчанию.

WSS — RFC 6455 binary, ping/pong, реальные TLS trust/hostname checks; реализовать cancellation, bounded I/O, backpressure. Нельзя отключать certificate verification, позволять неправильный SNI или выдавать `cloudflare.com` как готовое реле. При неоднозначном исходе доставки payload не повторять.

HTTP/2 media (`/api`, HEAD+POST, ALPN h2) перенести после достижения работоспособности основного транспорта. Если Apple API не даёт надёжно проверить требуемый ALPN/потоки, указать ограничение и отложить фичу, не имитировать успешный h2. Известный Worker может обрывать сессию после 16 MiB: это отдельное серверное ограничение, не iOS-баг.

### 2.3 Диагностика

- Реальные измерения: наличие локального listener, активные/ожидающие MTProto-сессии, выбранный режим, категории отказов, TCP/WSS/relay/DC/media в пределах приватности.
- Доступная сеть: Wi-Fi или cellular, IPv4/IPv6/double-stack, честно обозначаемые доступные сведения. DNS/NAT64 отражать только если обнаружены корректно; PLMN/APN/Private DNS Android напрямую в iOS не переносить.
- Метрики DNS/TCP/TLS/HTTP показывать только если фактически измерены. Не подставлять нули и вычисленные догадки вместо отсутствующих значений.
- Сбор обезличенных диагностических кодов, строгий whitelist, конечный буфер; экспорт с предпросмотром и явным действием пользователя. Без секретов, IP-адресов, доменов, путей реле, Telegram ID и payload.
- Сетевой переход закрывает несовместимые соединения, очищает stale routes/pools и допускает новые подключения; никакого обещания бесшовности.

### 2.4 Интерфейс

Три основных вкладки: **Главная**, **Диагностика**, **Настройки**. Логотип и название сохраняются из лицензированного оригинала. UI — нативный SwiftUI Premium Minimal, вдохновлённый Android 0.4.0, адаптированный под Apple HIG, Safe Area, Dynamic Type, VoiceOver, локализацию RU/EN, iPhone portrait/landscape where practical. Тёмная/светлая/системная темы; анимации умеренные, Reduce Motion соблюдается. Никаких поддельных цифр и фальшивой кнопки «Подключено».

Главная: статус, явное начало/окончание сессии только когда движок реально интегрирован; локальный адрес и копирование ссылки; краткий выбранный транспорт. Диагностика: состояния и ошибки, безопасный экспорт, информация о сети. Настройки: режимы, WSS-реле, CF Worker URLs, совместимые CF-домены, Fake TLS, порт, настройки темы, обновления и сведения о проекте. Пароли/URL с ключом маскировать.

### 2.5 Хранение и безопасность

- Keychain: MTProto secret, защищённые relay/Worker URL и чувствительные параметры; при повреждении данных **не** создавать молча новый секрет и **не** очищать старый.
- UserDefaults: только нечувствительные настройки: тема, вкладка, период проверки обновлений, неcredential-bearing flags.
- Включить App Transport Security; не создавать insecure exceptions ради удобства; локальный listen — по loopback без LAN.
- Нет телеметрии по умолчанию, нет стороннего рекламного SDK, нет секретов в аналитике/исключениях.
- Не добавлять не относящиеся к функции расширения, фальшивый аудиоплеер/VoIP, бесконечные `BGTaskScheduler` loops или private APIs ради удержания процесса.
- Лицензия MIT для перенесённого кода, точные NOTICE и источники графики.

### 2.6 Обновления и дистрибуция

- Информация о версиях — проверяемый GitHub Release metadata только в качестве информационного центра, возможна кнопка открытия TestFlight / App Store при реальной опубликованной ссылке.
- iOS не использует Android APK инсталлятор; **не пытаться сделать автоматическую установку IPA из приложения** и не выдавать GitHub Release как доверенную установку.
- Каналы Stable / Preview показываются только если реально доступны. iOS фоновые периодические проверки best-effort, никакой гарантии интервалов 15 минут.
- Сборка с code-sign на Mac и подпись через аккаунт владельца; credential secrets не хранить в репозитории.
- App Store review: отдельно проверить требования к VPN apps, если рассматривается Network Extension Packet Tunnel; без явного согласия владельца не менять тип продукта.

## 3. Архитектура

```
TGWSApp (SwiftUI, iPhone only)
  ├─ AppModel / RuntimeController / Observable state
  ├─ Home / Diagnostics / Settings / Update Center
  ├─ KeychainStore (секреты и credential-bearing URLs)
  └─ iOS lifecycle & route-monitor adapters

TGWSCore (Swift Package, без SwiftUI)
  ├─ Protocol: handshake / cipher context / Fake TLS / framing
  ├─ Proxy: loopback listener / sessions / bounded buffering
  ├─ Transports: WSS / TCP / WSS relay / CF worker / HTTP2 media (later)
  ├─ Routing: route selection / backoff / abort / network generation
  ├─ Config: modes / validation / Telegram link
  └─ Diagnostics: immutable snapshots, redaction, telemetry timing
```

Core должен тестироваться без iPhone с local fake peers; I/O interfaces инъектируются. Асинхронность через Swift Concurrency actors/cancellation или другие проверенные механизмы без гонок; UI не блокирует MainActor. Не копировать механически Java `Thread`/Android `Service` в iOS.

## 4. Порядок разработки — обязательные этапы

**F0. Feasibility** — собрать и проверить на iPhone минимальный порт локального listener + достаточный реальный MTProto handshake + Telegram link. Провести фоновые тесты по `IOS_FEASIBILITY.md`. Если FAIL — остановить работу и описать варианты для решения владельцем. Нельзя объявлять поддержкой фона то, что было проверено только на симуляторе.

**F1. Native protocol core** — побайтовое портирование Handshake, AES-CTR, MTProto framing, Fake TLS, сохраняя тест-векторы Android/Flowseal. Провести negative tests и fuzz/property tests для парсера. Локальная эмуляция peer не означает успех Telegram.

**F2. Reliable transport** — direct WSS / TCP, relay-only, Network.framework/URLSession, backpressure, Ping/Pong, switch Wi-Fi/cellular, IPv6, close/cancel semantics, bounded queues.

**F3. Auto-CF + media** — совместимость с уже заданными Worker URLs и CF Proxy, ограниченная ротация, запрет payload replay; позже HTTP/2 только при доказанной поддержке.

**F4. UX + storage** — Premium Minimal три вкладки, доступность RU/EN, Keychain, обновления, нативные настройки; перенести текущий логотип из исходников с соблюдением лицензии.

**F5. QA & release** — unit/integration/XCUITest, GitHub Actions on macOS, physical iPhone QA, TestFlight, Security and performance review. Stable только после физической проверки и разрешения владельца.

## 5. Gate / критерии приёмки

- F0: на физическом iPhone Telegram реально передаёт текст и медиа через TGWS при задокументированном жизненном цикле; установлены ограничения фона. Отдельное решение владельца: годен ли сценарий.
- F1: pinned vector parity, 100% критических протокольных кейсов, все отрицательные сценарии не падают; корректность secret и направления AES-CTR.
- F2: 2/2 working basic transports на локальных test fixtures; relay-only leak test negative; никаких hang/неограниченных буферов.
- F3: подтвержденные рабочие маршруты и явные failure states; формат handshake соответствует серверу; HD upload limitation documented.
- F4: три экрана работают, секрет не попадает в plaintext storage, доступны VoiceOver/Dynamic Type и RU/EN; UI статус совпадает с transport runtime.
- F5: CI и unit/integration зелёные, iPhone test logs owner-reviewed, лицензии/логотип проверены, build подпись и распространение проверены.

## 6. Обязательные материалы от Codex

- Исходники Swift, работающий (там, где подтверждён) Xcode проект, Swift Package tests, GitHub Actions.
- `PORTING_REPORT.md` — Android commit SHA, Flowseal SHA, матрица классов, отклонения.
- `FEASIBILITY_REPORT.md` — фактические iOS/Telegram behavior, run results, неформализованные ограничения.
- `SECURITY_REVIEW.md` — шифрование, TLS, секреты, логи, угрозы, тесты.
- `RELEASE_CHECKLIST.md` — реальные шаги архивации/подписи/TestFlight.
- Короткий changelog каждого этапа, открытые блокеры с приоритетами и exact reproduction.

## 7. Запреты

Нет фиктивного MTProto-прокси, mock status masquerading as real, отсутствующих фактически тестов, отключения TLS validation, захардкоженных чужих Worker URL, секретов/токенов в коммитах, silent VPN activation, попыток замаскировать App background execution сомнительными Background Modes, слияния в Android исходный repo, публикации Stable без подтверждения владельца. Не гарантировать обход блокировок, фоновую работу и доступность чужой инфраструктуры.

## 8. Источники

- Android project: https://github.com/Kust3r3nk0/TGWS-Android
- Flowseal reference: https://github.com/Flowseal/tg-ws-proxy
- Apple NWListener: https://developer.apple.com/documentation/network/nwlistener
- Apple Network Extension provider deployment: https://developer.apple.com/documentation/technotes/tn3134-network-extension-provider-deployment
- Apple Background Modes: https://developer.apple.com/documentation/xcode/configuring-background-execution-modes
- Apple Packet Tunnel: https://developer.apple.com/documentation/networkextension/nepackettunnelprovider
- App Review: https://developer.apple.com/app-store/review/guidelines/