﻿Процедура ПриДобавленииПодсистемы(Описание) Экспорт
    Описание.Имя = Метаданные.Имя;
    Описание.Версия = Метаданные.Версия;
    // Требуется библиотека стандартных подсистем.
    Описание.ТребуемыеПодсистемы.Добавить("СтандартныеПодсистемы");
КонецПроцедуры
Процедура ПриДобавленииОбработчиковОбновления(Обработчики) Экспорт
	Обработчик = Обработчики.Добавить();
	Обработчик.НачальноеЗаполнение = Истина;
	Обработчик.Процедура = "ОбновлениеИнформационнойБазыУчетПациентов.ОбновлениеКонтактнойИнформации";
	
	Обработчик = Обработчики.Добавить();
	Обработчик.Версия              = "1.0.1.11";
	Обработчик.Процедура           = "ОбновлениеИнформационнойБазыУчетПациентов.ЗаполнениеПервичнойБеседы";
	
	
КонецПроцедуры
Процедура ПередОбновлениемИнформационнойБазы() Экспорт
КонецПроцедуры
Процедура ПослеОбновленияИнформационнойБазы(Знач ПредыдущаяВерсия, Знач ТекущаяВерсия,
        Знач ВыполненныеОбработчики, ВыводитьОписаниеОбновлений, МонопольныйРежим) Экспорт
КонецПроцедуры
Процедура ПриПодготовкеМакетаОписанияОбновлений(Знач Макет) Экспорт
КонецПроцедуры
Процедура ПриДобавленииОбработчиковПереходаСДругойПрограммы(Обработчики) Экспорт
КонецПроцедуры
Процедура ПриОпределенииРежимаОбновленияДанных(РежимОбновленияДанных, СтандартнаяОбработка) Экспорт
КонецПроцедуры 
Процедура ПриЗавершенииПереходаСДругойПрограммы(Знач ПредыдущееИмяКонфигурации, Знач ПредыдущаяВерсияКонфигурации, Параметры) Экспорт
КонецПроцедуры

#Область СлужебныеПроцедурыИФункции

Процедура ОбновлениеКонтактнойИнформации () Экспорт
	Если Не ОбщегоНазначения.ПодсистемаСуществует("СтандартныеПодсистемы.КонтактнаяИнформация") Тогда
		Возврат;
	КонецЕсли;
	
	МодульУправлениеКонтактнойИнформацией = ОбщегоНазначения.ОбщийМодуль("УправлениеКонтактнойИнформацией");
	
	ПараметрыВида = МодульУправлениеКонтактнойИнформацией.ПараметрыВидаКонтактнойИнформации("Адрес");
	ПараметрыВида.Вид = "АдресКонтрагента";
	ПараметрыВида.МожноИзменятьСпособРедактирования = Истина;
	ПараметрыВида.РазрешитьВводНесколькихЗначений = Истина;
	//ПараметрыВида.Порядок = 1;
	МодульУправлениеКонтактнойИнформацией.УстановитьСвойстваВидаКонтактнойИнформации(ПараметрыВида);
	
	ПараметрыВида = МодульУправлениеКонтактнойИнформацией.ПараметрыВидаКонтактнойИнформации("Skype");
	ПараметрыВида.Вид = "SkypeКонтрагента";
	ПараметрыВида.МожноИзменятьСпособРедактирования = Истина;
	ПараметрыВида.РазрешитьВводНесколькихЗначений = Истина;
	//ПараметрыВида.Порядок = 2;
	МодульУправлениеКонтактнойИнформацией.УстановитьСвойстваВидаКонтактнойИнформации(ПараметрыВида);
	
	ПараметрыВида = МодульУправлениеКонтактнойИнформацией.ПараметрыВидаКонтактнойИнформации("АдресЭлектроннойПочты");
	ПараметрыВида.Вид = "EmailКонтрагента";
	ПараметрыВида.МожноИзменятьСпособРедактирования = Истина;
	ПараметрыВида.РазрешитьВводНесколькихЗначений = Истина;
	//ПараметрыВида.Порядок = 2;
	МодульУправлениеКонтактнойИнформацией.УстановитьСвойстваВидаКонтактнойИнформации(ПараметрыВида);

КонецПроцедуры

// Заполняет значениями по умолчанию предопределенную процедуру ПервичнаяБеседа
Процедура ЗаполнениеПервичнойБеседы() Экспорт
	Элемент = Справочники.Процедуры.ПервичнаяБеседа.ПолучитьОбъект();
	Элемент.Длительность = 45;
	Элемент.МаксимальноеКоличествоКлиентов = 1;
	Элемент.МаксимальноеКоличествоСпециалистов = 1;
	Элемент.Записать();
КонецПроцедуры
	
#КонецОбласти