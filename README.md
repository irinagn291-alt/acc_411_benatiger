# Benatiger

Локальная игра для iPhone и iPad. Идентификатор фабрики — **acc_411**. Bundle ID — `com.tigerbureau.luckytiger`. Проект [LuckyTiger.xcodeproj](LuckyTiger.xcodeproj), схема `LuckyTiger`, минимальная версия iOS 17.

## Описание игры

> Take the night shift at a lost-property bureau. Hear both claimants, work the mechanism on the bench, and put the evidence on the receipt before you press the brass stamp. Over four nights, twelve ordinary things make their way home. Keep your earlier receipts. The last case needs two of them.

В кампании 4 ночи, 12 дел, 24 посетителя, 48 адресных вопросов и ответов, 36 физических наблюдений и 12 писем. Для каждого дела предусмотрены отдельные реакции на ошибочного получателя и слабое основание. Основная редакция — en-GB. В бинарь входят en-US, zh-Hant и ar. Вся кампания, 74 векторных иллюстрации, иконка и 10 звуковых ресурсов находятся в пакете приложения.

## Текущая ревизия дедукции

В делах термоса, компостера, метронома и фонаря можно приложить к наблюдению показание, полученное по конкретному вопросу. Если выбран другой вопрос, дело решается двумя проверяемыми уликами. На квитанции есть разворачиваемая подсказка о связках. Возражение сохраняет выбранные карточки и указывает, чего не хватает.

Расположение посетителей задано для каждого дела. Черновики, разговоры и выданные квитанции из сохранения v1 по-прежнему относятся к тем же персонажам. Сценарии, кадры и результаты этой ревизии собраны в [отчёте по дедукции](../../artifacts/genesis/com.tigerbureau.luckytiger/deduction-qa/REPORT.md).

## Исходники продукта

- [BureauApp.swift](Game/BureauApp.swift) — вход, приёмная, доска, письма, воспроизведение звуков.
- [CaseBook.swift](Game/CaseBook.swift) — декларативные дела, наблюдения, вопросы, решения, квитанции и локальное сохранение.
- [Desk.swift](Game/Desk.swift) — верстак, разговор, форма квитанции и доступные действия.

Компилятор получил эти три файла. [Список Release](QA/evidence/Release-fullscreen.SwiftFileList) · [Журнал сборки](QA/evidence/ios-release-fullscreen.log) · [Содержимое пакета](QA/evidence/fullscreen-release-bundle-files.txt).

## Воспроизведение проверки

XCUITest находится в отдельном таргете [LuckyTigerUITests](Tests/BureauUITests.swift). Тест чистого первого запуска использует обычное хранилище на новом временном устройстве. Остальные UI-тесты запускают пустые именованные хранилища в Debug, проходят через обычные экранные действия и правила. Сборка Release всегда использует штатное хранилище.

Из корня фабрики, с UDID шаблона нужной модели:

```sh
python3 gf/genesis/simulator_pool.py TEMPLATE_UDID bash output/concepts23nov/acc_411_the_lucky_tiger/QA/simulator.sh LOCAL_RUN
```

[Отдельные проверки правил](QA/evidence/fullscreen-campaign-rules.log) проверяют 12 дел, первый альтернативный путь, отклонение слабых и неверных связок, одну выдачу на дело, сохранение черновика и девять сочетаний вопросов, включая пропуск обоих. [Первый прототип правил](QA/evidence/box-rules.log) фиксирует обе достаточные связки шкатулки.

[Фрагмент игровых звуков](QA/evidence/gameplay-sounds.wav) собран из WAV-файлов игры в порядке «звонок, щелчок, мелодия, штамп».

## Полноразмерная компоновка на iPhone 18 Pro

Все шесть итоговых UI-тестов прошли на iOS 27.2. [Результат Xcode](QA/evidence/iphone-final/UI.xcresult) · [Лог](QA/evidence/iphone-final/test.log) · [Список выдач из прогона](QA/evidence/iphone-final/releases.txt).

| Проверка через интерфейс | Свидетельство |
|---|---|
| Чистый первый запуск, звонок, приёмная и вопрос о мелодии | [Первый экран](QA/evidence/iphone-final/frames/01-first-launch.png) · [Приёмная](QA/evidence/iphone-final/frames/02-reception.png) |
| Возражение на мелодию, повторное чтение из блокнота, открытие петли, исправленная квитанция | [Возражение](QA/evidence/iphone-final/frames/03-rejected-melody.png) · [Петля и прокладка](QA/evidence/iphone-final/frames/05-opened-paper-shim.png) · [Исправленная квитанция](QA/evidence/iphone-final/frames/07-corrected-receipt.png) |
| Вторая ветка шкатулки и продолжение после завершения процесса | [Восстановленный разговор](QA/evidence/iphone-final/frames/11-restored-conversation.png) · [Восстановленный черновик](QA/evidence/iphone-final/frames/12-restored-draft.png) |
| Разные поздние осмотры, в том числе неверные положения перед повторной попыткой | [Метроном](QA/evidence/iphone-final/frames/campaign-07-metronome-fourth-beat.png) · [Шторка фонаря](QA/evidence/iphone-final/frames/campaign-09-lantern-wrong-shutter.png) · [Совмещение кадра](QA/evidence/iphone-final/frames/campaign-10-camera-misaligned.png) · [Подбор зубцов](QA/evidence/iphone-final/frames/campaign-11-keys-wrong-teeth.png) |
| Полный прогон из пустого сохранения, 12 выдач в обычном UI, финал с двумя подлинными квитанциями | [Финальная квитанция](QA/evidence/iphone-final/frames/campaign-13-finale.png) · [Закрытие бюро](QA/evidence/iphone-final/frames/campaign-14-archive.png) |
| Арабский со звуком, выключенным в игре, и увеличенным текстом. Традиционный китайский с длинными репликами | [Разговор ar](QA/evidence/iphone-final/frames/locale-ar-large-conversation.png) · [Карточки ar](QA/evidence/iphone-final/frames/locale-ar-large-evidence.png) · [Разговор zh-Hant](QA/evidence/iphone-final/frames/locale-zh-Hant-conversation.png) · [Карточки zh-Hant](QA/evidence/iphone-final/frames/locale-zh-Hant-evidence.png) |

После уменьшения панели фотоаппарата [повторный прогон](QA/evidence/iphone-camera/UI.xcresult) снова оформил [все 12 выдач](QA/evidence/iphone-camera/releases.txt). [Неверное положение](QA/evidence/iphone-final/frames/campaign-10-camera-misaligned.png) · [Совпадение до подтверждения](QA/evidence/iphone-final/frames/campaign-10-camera-aligned-before-check.png).

После исправления зоны касания [прямой осмотр и горизонтальный жест](QA/evidence/iphone-final/frames/07i-phone-direct-hinge.png) также прошли в портрете. Это заявленная ориентация iPhone.

В сквозном прогоне использованы нажатия и прокрутка XCUITest. Все игровые данные созданы обычными действиями в приложении. Логика ошибочных вердиктов каждого отдельного дела проверена дополнительно на уровне модели.

Финальная [Release-сборка для устройства](QA/Builds/Fullscreen-Release-iphoneos/LuckyTiger.app) не подписана. [Список Swift-файлов Debug для симулятора](QA/evidence/Debug-fullscreen.SwiftFileList) совпадает со списком Release.

## Размер игрового поля до и после

Отметки сняты с PNG одного и того же состояния на каждом устройстве. Размер игрового поля измерен по видимым границам с округлением до 10 px. Ширина шкатулки измерена по внешнему контуру корпуса, ширина крупного плана — по заливке карточки петли. [Замеры объектов](QA/evidence/scene-measurements.txt).

| Устройство | Приёмная до → после | Верстак до → после | Шкатулка в приёмной | Крупный план петли |
|---|---|---|---|---|
| iPhone 18 Pro, портрет | 1100 × 680 → 1210 × 2010 px | 1100 × 740 → 1210 × 2010 px | 402 → 889 px, 33% → 74% ширины кадра | 383 → 538 px |
| iPad Pro 13″ M5, портрет | 1120 × 620 → 2060 × 2430 px | 1180 × 670 → 2060 × 2430 px | 368 → 1507 px, 18% → 73% ширины кадра | 349 → 905 px |

- **iPhone.** Приёмная [до](QA/evidence/iphone-full/frames/02-reception.png) и [после](QA/evidence/iphone-final/frames/02-reception.png). Петля [до](QA/evidence/iphone-full/frames/05-opened-paper-shim.png) и [после](QA/evidence/iphone-final/frames/05-opened-paper-shim.png).
- **iPad.** Приёмная [до](QA/evidence/ipad/frames/02-reception.png) и [после](QA/evidence/ipad-final/frames/02-reception.png). Петля [до](QA/evidence/ipad/frames/05-opened-paper-shim.png) и [после](QA/evidence/ipad-final/frames/05-opened-paper-shim.png).
- **iPad, альбом.** [Приёмная](QA/evidence/ipad-orientation/frames/06i-room-landscape.png) · [Открытая петля](QA/evidence/ipad-orientation/frames/06i-hinge-landscape.png) · [Квитанция](QA/evidence/ipad-orientation/frames/06i-receipt-landscape.png).
- **Фотоаппарат на iPad.** [Не совпало](QA/evidence/ipad-final/frames/campaign-10-camera-misaligned.png) · [Совпало до проверки](QA/evidence/ipad-final/frames/campaign-10-camera-aligned-before-check.png).

## Точки касания

Первый тест ориентаций на iPad выявил, что accessibility-рамка метки осмотра охватывала весь верстак. Сохранённое событие XCUITest попало в центр сцены с координатами (516, 691,5) pt. После исправления у каждой кнопки осмотра своя область 54 × 54 pt, а горизонтальный жест работает на отдельном слое стола. Прямое касание в портрете открыло наблюдение «Polished rim». Касания в альбоме удержали ось, открыли крышку и позволили сравнить прокладку с подписью.

[Рамки кнопок и ориентации](QA/evidence/ipad-orientation/touch-areas.txt) · [Дерево accessibility блокнота](QA/evidence/ipad-orientation/attachments/BA02BEA3-090C-471A-B5CA-3A8273A112D9.txt) · [Кадр записи в блокноте](QA/evidence/ipad-orientation/frames/06i-inspection-notebook.png).

## Результаты Xcode

| Прогон | Результат |
|---|---|
| [Пилот iPhone](QA/evidence/prototype/UI.xcresult) | Воспроизведён и исправлен вылет при переходе к следующему шагу осмотра. |
| [Предыдущая компоновка iPhone](QA/evidence/iphone-full/UI.xcresult) | 5 UI-тестов прошли. |
| [Предыдущая компоновка iPad](QA/evidence/ipad/UI.xcresult) | 2 UI-теста прошли. |
| [iPhone после перехода к полноразмерным сценам](QA/evidence/iphone-fullscreen/UI.xcresult) | 5 UI-тестов прошли. |
| [iPhone после уплотнения панели фотоаппарата](QA/evidence/iphone-camera/UI.xcresult) | Сквозной прогон прошёл, 12 выдач. |
| [iPad Pro 13″ M5, полный прогон](QA/evidence/ipad-fullscreen/UI.xcresult) | Шкатулка, восстановление и [все 12 выдач](QA/evidence/ipad-fullscreen/releases.txt) прошли. Четвёртый тест обнаружил неверную область касания. |
| [iPad Pro 13″ M5, повтор после исправления](QA/evidence/ipad-orientation/UI.xcresult) | Тест прямого осмотра в портрете и альбоме прошёл. |
| [Итоговый iPhone 18 Pro](QA/evidence/iphone-final/UI.xcresult) | 6 тестов прошли, включая прямые касания, горизонтальный жест и 12 выдач. |
| [Итоговый iPad Pro 13″ M5](QA/evidence/ipad-final/UI.xcresult) | Все 4 теста прошли, включая [12 выдач](QA/evidence/ipad-final/releases.txt) и прямой осмотр в портрете и альбоме. |

[Игровой фрагмент, 25,6 с](QA/evidence/fullscreen-playthrough.mov) показывает приёмную, шкатулку, возражение и исправленную выдачу. [Прямой осмотр на iPad, 19,1 с](QA/evidence/direct-inspection.mov) показывает поворот и действия на самом предмете. Поворот кадра выровнен при обработке записи. [Звук из ресурсов игры](QA/evidence/gameplay-sounds.wav) приложен отдельно.
