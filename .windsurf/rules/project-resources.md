---
trigger: model_decision
description: Использовать при импорте констант, обработке ошибок, логировании или создании лоадеров.
---

Особенные виджеты / файлы ->
1. "lib/presentation/widgets/loading_tile.dart" - используется вместо самого виджета пока данные для него загружаются. например вместо имени юзер, пока данные о нём подгружаются с сервера.
2. "lib/core/constants/constants.dart" - используется как хранилище для ссылок, api ключей и других констант.
3. "lib/core/error/failure.dart" - используется для дропа ошибок из data -в-> domain + presentation.
4. "lib/core/logging" - это папка с файлами, реализацией классов лоигрования talker ("... extends TalkerLog")