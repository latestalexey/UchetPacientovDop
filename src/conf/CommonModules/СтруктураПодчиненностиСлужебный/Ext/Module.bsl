﻿////////////////////////////////////////////////////////////////////////////////
// Подсистема "Связанные документы".
// 
////////////////////////////////////////////////////////////////////////////////

#Область СлужебныйПрограммныйИнтерфейс

////////////////////////////////////////////////////////////////////////////////
// Добавление обработчиков служебных событий (подписок).

// См. описание этой же процедуры в модуле СтандартныеПодсистемыСервер.
Процедура ПриДобавленииОбработчиковСлужебныхСобытий(КлиентскиеОбработчики, СерверныеОбработчики) Экспорт
	
	// СЕРВЕРНЫЕ ОБРАБОТЧИКИ.
	
	ИмяСобытия = "СтандартныеПодсистемы.БазоваяФункциональность\ПриДобавленииПереименованийОбъектовМетаданных";
	СерверныеОбработчики[ИмяСобытия].Добавить("СтруктураПодчиненностиСлужебный");
	
КонецПроцедуры

////////////////////////////////////////////////////////////////////////////////
// Обработчики служебных событий.


// Заполняет переименования тех объектов метаданных, которые невозможно
//   автоматически найти по типу, но ссылки на которые требуется сохранять
//   в базе данных (например: подсистемы, роли).
//
// См. также:
//   ОбщегоНазначения.ДобавитьПереименование().
//
Процедура ПриДобавленииПереименованийОбъектовМетаданных(Итог) Экспорт
	
	Библиотека = "СтандартныеПодсистемы";
	
	СтароеИмя = "Роль.ИспользованиеСтруктурыПодчиненности";
	НовоеИмя  = "Роль.ПросмотрСвязанныеДокументы";
	ОбщегоНазначения.ДобавитьПереименование(Итог, "2.3.3.5", СтароеИмя, НовоеИмя, Библиотека);
	
КонецПроцедуры


#КонецОбласти
