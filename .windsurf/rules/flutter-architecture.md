---
trigger: model_decision
description: Использовать при написании кода на Dart/Flutter, создании новых фич, верстке UI или рефакторинге.
---

Требования к коду ->
1. Код нашего приложения разбит на "lib/features/...". Каждая feature имеет структуру, эталонной "lib/features/_empty". А именно, data/data_source, data/models, data/repositories, domain/entities, domain/repositories, domain/usecases, presentation/cubit/имя_кубита, presentation/pages, presentation/widgets.
2. Слой domain должен использовать структуры "Future<Either<Failure, ...>>" для обработки ошибок и данных между data и presentation (использовать dartz).
3. Слой domain должен содержать Equatable классы в "entities".
4. Слой data должен наследовать классы domain. Но расширить их добавив, toEntity, fromEntity.
5. Хорошей парктикой будет, использовать цвет theme-of-context, нежели РУЧНЫЕ значения.
6. Хорошей парктикой будет, ВЫНЕСТИ БЗИНЕС ЛОГИКУ и СОСТОЯНИЯ в cubit-ы.
7. Наш проект использует декларативный подход к стилизации UI через цепочки методов с точечной нотацией например Text('Текст').padding(all: 16).backgroundColor(Colors.primary). Через пакет styled_widget.

Разделение кода интрфейса ->
1. Код КАРТОЧКИ/СТРАНИЦЫ, всегда должен быть РАЗБИТ, но МНОГОРАЗОВЫЕ НЕЗАВИСИМЫЕ УНИВЕРСАЛЬНЫЕ виджеты, для этого feature.
2. Фактически dart файлы страниц/карточек/форм, будут лишь сборочным пунктом для разбитых на файлы виджетов.
3. Хорошей практикой будет расширение виджета, для повторного использования в рамках того-же feature.