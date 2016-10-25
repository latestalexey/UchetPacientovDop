﻿
#Область ОбработчикиСобытийФормы

&НаСервере
Процедура ПриСозданииНаСервере(Отказ, СтандартнаяОбработка)
	
	Если Параметры.Свойство("АвтоТест") Тогда // Возврат при получении формы для анализа.
		Возврат;
	КонецЕсли;
	
	РасписаниеДня = Параметры.РасписаниеРаботы;
	РасписаниеСмен = Новый Массив;
	Для Каждого Строка Из РасписаниеДня Цикл
		Если РасписаниеСмен.Найти(Строка.Смена) = Неопределено Тогда
			РасписаниеСмен.Добавить(Строка.Смена);
		КонецЕсли;
	КонецЦикла;
		
	Для Каждого Смена Из РасписаниеСмен Цикл
		НС = РасписаниеРаботы.Добавить();
		ЗаполнитьЗначенияСвойств(НС, Смена);
		НС.Смена = Смена;		
	КонецЦикла;
	РасписаниеРаботы.Сортировать("ВремяНачала");
	
КонецПроцедуры

&НаКлиенте
Процедура ПередЗакрытием(Отказ, ЗавершениеРаботы, ТекстПредупреждения, СтандартнаяОбработка)
	
	Оповещение = Новый ОписаниеОповещения("ВыбратьИЗакрыть", ЭтотОбъект);
	ОбщегоНазначенияКлиент.ПоказатьПодтверждениеЗакрытияФормы(Оповещение, Отказ, ЗавершениеРаботы);
	
КонецПроцедуры

#КонецОбласти

#Область ОбработчикиСобытийЭлементовШапкиФормы

&НаКлиенте
Процедура РасписаниеРаботыПриОкончанииРедактирования(Элемент, НоваяСтрока, ОтменаРедактирования)
		
	Если ОтменаРедактирования Тогда
		Возврат;
	КонецЕсли;
	
	ГрафикиРаботыКлиентСервер.ВосстановитьПорядокСтрокКоллекцииПослеРедактирования(РасписаниеРаботы, "ВремяНачала", Элемент.ТекущиеДанные);
	
КонецПроцедуры

#КонецОбласти

#Область ОбработчикиКомандФормы

&НаКлиенте
Процедура ОК(Команда)
	
	ВыбратьИЗакрыть();
	
КонецПроцедуры

&НаКлиенте
Процедура Отмена(Команда)
	
	Модифицированность = Ложь;
	ОповеститьОВыборе(Неопределено);
	
КонецПроцедуры

#КонецОбласти

#Область СлужебныеПроцедурыИФункции

&НаСервере
Процедура РазвернутьРасписаниеРаботыПоСменам()
	ТаблицаСмен = РасписаниеРаботы.Выгрузить(,"Смена");
	ТаблицаСмен.Свернуть("Смена");
	РасписаниеРаботы.Очистить();
	Для Каждого Смена Из ТаблицаСмен Цикл
		Для Каждого Проц Из Смена.Смена.Процедуры Цикл
			НС = РасписаниеРаботы.Добавить();
			НС.Смена = Смена.Смена;
			НС.ВремяНачала = Проц.ВремяНачала;
			НС.ВремяОкончания = Проц.ВремяОкончания;
		КонецЦикла;
	КонецЦикла;
КонецПроцедуры

&НаКлиенте
Функция РасписаниеДня()
	
	Отказ = Ложь;
	
	РасписаниеДня = Новый Массив;
	
	ОкончаниеДня = Неопределено;
	РазвернутьРасписаниеРаботыПоСменам();
	Для Каждого СтрокаРасписания Из РасписаниеРаботы Цикл
		ИндексСтроки = РасписаниеРаботы.Индекс(СтрокаРасписания);
		Если СтрокаРасписания.ВремяНачала > СтрокаРасписания.ВремяОкончания 
			И ЗначениеЗаполнено(СтрокаРасписания.ВремяОкончания) Тогда
			ОбщегоНазначенияКлиентСервер.СообщитьПользователю(
				НСтр("ru = 'Время начала больше времени окончания'"), ,
				СтроковыеФункцииКлиентСервер.ПодставитьПараметрыВСтроку("РасписаниеРаботы[%1].ВремяОкончания", ИндексСтроки), ,
				Отказ);
		КонецЕсли;
		Если СтрокаРасписания.ВремяНачала = СтрокаРасписания.ВремяОкончания Тогда
			ОбщегоНазначенияКлиентСервер.СообщитьПользователю(
				НСтр("ru = 'Длительность интервала не определена'"), ,
				СтроковыеФункцииКлиентСервер.ПодставитьПараметрыВСтроку("РасписаниеРаботы[%1].ВремяОкончания", ИндексСтроки), ,
				Отказ);
		КонецЕсли;
		Если ОкончаниеДня <> Неопределено Тогда
			Если ОкончаниеДня > СтрокаРасписания.ВремяНачала 
				Или Не ЗначениеЗаполнено(ОкончаниеДня) Тогда
				ОбщегоНазначенияКлиентСервер.СообщитьПользователю(
					НСтр("ru = 'Обнаружены пересекающиеся интервалы'"), ,
					СтроковыеФункцииКлиентСервер.ПодставитьПараметрыВСтроку("РасписаниеРаботы[%1].ВремяНачала", ИндексСтроки), ,
					Отказ);
			КонецЕсли;
		КонецЕсли;
		ОкончаниеДня = СтрокаРасписания.ВремяОкончания;
		РасписаниеДня.Добавить(Новый Структура("ВремяНачала, ВремяОкончания, Смена", СтрокаРасписания.ВремяНачала, СтрокаРасписания.ВремяОкончания, СтрокаРасписания.Смена));
	КонецЦикла;
	
	Если Отказ Тогда
		Возврат Неопределено;
	КонецЕсли;
	
	Возврат РасписаниеДня;
	
КонецФункции

&НаКлиенте
Процедура ВыбратьИЗакрыть(Результат = Неопределено, ДополнительныеПараметры = Неопределено) Экспорт
	
	РасписаниеДня = РасписаниеДня();
	Если РасписаниеДня = Неопределено Тогда
		Возврат;
	КонецЕсли;
	
	Модифицированность = Ложь;
	ОповеститьОВыборе(Новый Структура("РасписаниеРаботы", РасписаниеДня));
	
КонецПроцедуры

&НаКлиенте
Процедура РасписаниеРаботыСменаПриИзменении(Элемент)
	Если ЗначениеЗаполнено(Элемент.Родитель.ТекущиеДанные.Смена) Тогда
		ЗаполнитьЗначенияСвойств(Элемент.Родитель.ТекущиеДанные, ПолучитьСтруктуруГрафикаИзСмены(Элемент.Родитель.ТекущиеДанные.Смена));
	КонецЕсли;
КонецПроцедуры

&НаСервере
Функция ПолучитьСтруктуруГрафикаИзСмены(Смена)
	ВремяСмены = Новый Структура;
	ВремяСмены.Вставить("ВремяНачала", Смена.ВремяНачала);
	ВремяСмены.Вставить("ВремяОкончания", Смена.ВремяОкончания);
	Возврат ВремяСмены;
КонецФункции

#КонецОбласти
