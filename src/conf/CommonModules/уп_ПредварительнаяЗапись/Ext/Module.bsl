﻿////////////////////////////////////////////////////////////////////////////////
// Модуль Предварительная запись
// Обеспечивает работу механизма предварительной записи
//  
////////////////////////////////////////////////////////////////////////////////
#Область ПрограммныйИнтерфейс

// Удаление документа Предварительная запись с проверкой ссылок на удаляемый документ.
Функция УдалитьПредварительнуюЗапись(ДокументСсылка) Экспорт
	
	РезультатУдаления = Ложь;
	
	Если Не ЗначениеЗаполнено(ДокументСсылка) Тогда 
		Возврат Истина;	
	КонецЕсли;	
	
    УдаляемыеОбъекты = Новый Массив;
    УдаляемыеОбъекты.Добавить(ДокументСсылка);
	
	УстановитьПривилегированныйРежим(Истина);
	
	НайденныеСсылки = НайтиПоСсылкам(УдаляемыеОбъекты); 
 
    Если НайденныеСсылки.Количество() > 1 Тогда
		ТекстСообщения = НСтр("ru='Имеются ссылки на документ!'");
		Сообщение = Новый СообщениеПользователю;
		Сообщение.Текст = ТекстСообщения;
		Сообщение.Сообщить();
		РезультатУдаления = Ложь;
	Иначе 
		Попытка
    		ДокументОбъект = ДокументСсылка.ПолучитьОбъект();
    		ДокументОбъект.Удалить(); 
			РезультатУдаления = Истина;
		Исключение 
			РезультатУдаления = Ложь;
    	КонецПопытки;
    КонецЕсли; 
    
	УстановитьПривилегированныйРежим(Ложь);
	
	Возврат РезультатУдаления;   
	
Конецфункции

// Получение расписания приема.
Функция ПолучитьРасписаниеПриема(ДатаНачала, ДатаОкончания, КратностьВремениЗаписи, СотрудникКабиентПереключатель, СписокЗначенийОтбора) Экспорт
	
	Запрос = Новый Запрос;
	Запрос.Текст = 
	"ВЫБРАТЬ
	|	ЗаписьНаПрием.Сотрудник КАК Измерение,
	|	НАЧАЛОПЕРИОДА(ЗаписьНаПрием.Период, ДЕНЬ) КАК Период
	|ИЗ
	|	РегистрСведений.уп_ГрафикРаботы КАК ЗаписьНаПрием
	|ГДЕ
	|	ЗаписьНаПрием.Период МЕЖДУ &ДатаНачала И &ДатаОкончания
	|	И НЕ ЗаписьНаПрием.Сотрудник = ЗНАЧЕНИЕ(Справочник.Контрагенты.ПустаяСсылка)
	|	И ВЫБОР
	|			КОГДА &СотрудникКабиентПереключатель = ""Сотрудник""
	|				ТОГДА ИСТИНА
	|			ИНАЧЕ ЛОЖЬ
	|		КОНЕЦ
	|	И ВЫБОР
	|			КОГДА &ЕстьОтбор
	|				ТОГДА ЗаписьНаПрием.Сотрудник В (&ОтборИзмерений)
	|			ИНАЧЕ ИСТИНА
	|		КОНЕЦ
	|
	|СГРУППИРОВАТЬ ПО
	|	ЗаписьНаПрием.Сотрудник,
	|	НАЧАЛОПЕРИОДА(ЗаписьНаПрием.Период, ДЕНЬ)
	|
	|ОБЪЕДИНИТЬ ВСЕ
	|
	|ВЫБРАТЬ
	|	ЗаписьНаПрием.Помещение,
	|	НАЧАЛОПЕРИОДА(ЗаписьНаПрием.Период, ДЕНЬ)
	|ИЗ
	|	РегистрСведений.уп_ГрафикРаботы КАК ЗаписьНаПрием
	|ГДЕ
	|	ЗаписьНаПрием.Период МЕЖДУ &ДатаНачала И &ДатаОкончания
	|	И НЕ ЗаписьНаПрием.Помещение = ЗНАЧЕНИЕ(Справочник.Помещения.ПустаяСсылка)
	|	И ВЫБОР
	|			КОГДА &СотрудникКабиентПереключатель = ""Помещение""
	|				ТОГДА ИСТИНА
	|			ИНАЧЕ ЛОЖЬ
	|		КОНЕЦ
	|	И ВЫБОР
	|			КОГДА &ЕстьОтбор
	|				ТОГДА ЗаписьНаПрием.Помещение В (&ОтборИзмерений)
	|			ИНАЧЕ ИСТИНА
	|		КОНЕЦ
	|
	|СГРУППИРОВАТЬ ПО
	|	ЗаписьНаПрием.Помещение,
	|	НАЧАЛОПЕРИОДА(ЗаписьНаПрием.Период, ДЕНЬ)
	|
	|УПОРЯДОЧИТЬ ПО
	|	Период,
	|	Измерение
	|;
	|
	|////////////////////////////////////////////////////////////////////////////////
	|ВЫБРАТЬ
	|	НАЧАЛОПЕРИОДА(ЗаписьНаПрием.Период, ДЕНЬ) КАК Период,
	|	ЗаписьНаПрием.Регистратор КАК Регистратор,
	|	ЗаписьНаПрием.Состояние КАК ТипЗаписи,
	|	ЗаписьНаПрием.ВремяНачала,
	|	ЗаписьНаПрием.ВремяОкончания,
	|	ЗаписьНаПрием.Сотрудник КАК Сотрудник,
	|	ЗаписьНаПрием.Помещение,
	|	ЗаписьНаПрием.Клиент
//	|	ЗаписьНаПрием.Телефон КАК Телефон,
//	|	ЗаписьНаПрием.Подтверждение,
//	|	ЗаписьНаПрием.Неявка,
//	|	ЗаписьНаПрием.Первичная,
//	|	ЗаписьНаПрием.ВидПрочейЗаписи КАК ВидПрочейЗаписи,
//	|	ЗаписьНаПрием.Комментарий
	|ИЗ
	|	РегистрСведений.уп_ГрафикРаботы КАК ЗаписьНаПрием
	|ГДЕ
	|	ЗаписьНаПрием.Период МЕЖДУ &ДатаНачала И &ДатаОкончания
	|	И НЕ ЗаписьНаПрием.Сотрудник = ЗНАЧЕНИЕ(Справочник.Контрагенты.ПустаяСсылка)
	|	И ЗаписьНаПрием.Регистратор ССЫЛКА Документ.уп_ПредварительнаяЗапись
	|	И ВЫБОР
	|			КОГДА &СотрудникКабиентПереключатель = ""Сотрудник""
	|				ТОГДА ИСТИНА
	|			ИНАЧЕ ЛОЖЬ
	|		КОНЕЦ
	|	И ВЫБОР
	|			КОГДА &ЕстьОтбор
	|				ТОГДА ЗаписьНаПрием.Сотрудник В (&ОтборИзмерений)
	|			ИНАЧЕ ИСТИНА
	|		КОНЕЦ
	|
	|ОБЪЕДИНИТЬ ВСЕ
	|
	|ВЫБРАТЬ
	|	НАЧАЛОПЕРИОДА(ЗаписьНаПрием.Период, ДЕНЬ),
	|	ЗаписьНаПрием.Регистратор,
	|	ЗаписьНаПрием.Состояние,
	|	ЗаписьНаПрием.ВремяНачала,
	|	ЗаписьНаПрием.ВремяОкончания,
	|	ЗаписьНаПрием.Сотрудник,
	|	ЗаписьНаПрием.Помещение,
	|	ЗаписьНаПрием.Клиент
//	|	ЗаписьНаПрием.Телефон,
//	|	ЗаписьНаПрием.Подтверждение,
//	|	ЗаписьНаПрием.Неявка,
//	|	ЗаписьНаПрием.Первичная,
//	|	ЗаписьНаПрием.ВидПрочейЗаписи,
//	|	ЗаписьНаПрием.Комментарий
	|ИЗ
	|	РегистрСведений.уп_ГрафикРаботы КАК ЗаписьНаПрием
	|ГДЕ
	|	ЗаписьНаПрием.Период МЕЖДУ &ДатаНачала И &ДатаОкончания
	|	И НЕ ЗаписьНаПрием.Помещение = ЗНАЧЕНИЕ(Справочник.Помещения.ПустаяСсылка)
	|	И ЗаписьНаПрием.Регистратор ССЫЛКА Документ.уп_ПредварительнаяЗапись
	|	И ВЫБОР
	|			КОГДА &СотрудникКабиентПереключатель = ""Помещение""
	|				ТОГДА ИСТИНА
	|			ИНАЧЕ ЛОЖЬ
	|		КОНЕЦ
	|	И ВЫБОР
	|			КОГДА &ЕстьОтбор
	|				ТОГДА ЗаписьНаПрием.Помещение В (&ОтборИзмерений)
	|			ИНАЧЕ ИСТИНА
	|		КОНЕЦ
	|
	|УПОРЯДОЧИТЬ ПО
	|	Период";
	
	Запрос.УстановитьПараметр("ДатаНачала", 	ДатаНачала);
	Запрос.УстановитьПараметр("ДатаОкончания",	ДатаОкончания);
	Запрос.УстановитьПараметр("ЕстьОтбор",		ЗначениеЗаполнено(СписокЗначенийОтбора));
	Запрос.УстановитьПараметр("ОтборИзмерений",	СписокЗначенийОтбора);
	Запрос.УстановитьПараметр("СотрудникКабиентПереключатель", СотрудникКабиентПереключатель);
		
	РезультатЗапроса = Запрос.ВыполнитьПакет();
	
	// Притягивание времени начала записи к шкале времени.
	ТаблицаЭлементов = РезультатЗапроса[1].Выгрузить();
	
	Для Каждого ТекЭлемент из ТаблицаЭлементов Цикл 
		
		Если Не Минута(ТекЭлемент.ВремяНачала) / КратностьВремениЗаписи = Цел(Минута(ТекЭлемент.ВремяНачала) / КратностьВремениЗаписи) Тогда 
			ТекЭлемент.ВремяНачала =  '00010101' + Час(ТекЭлемент.ВремяНачала) * 60 * 60 + Окр(Минута(ТекЭлемент.ВремяНачала) / КратностьВремениЗаписи) * КратностьВремениЗаписи * 60;	
		КонецЕсли;
		
	КонецЦикла;
	
	СтруктураРезультата = Новый Структура;
	СтруктураРезультата.Вставить("АдресИзмерений",		ПоместитьВоВременноеХранилище(РезультатЗапроса[0].Выгрузить()));
	СтруктураРезультата.Вставить("АдресЭлементов", 		ПоместитьВоВременноеХранилище(ТаблицаЭлементов));

	Возврат СтруктураРезультата;
	
КонецФункции // ПолучитьРасписаниеПриема()

// Изменение некоторых параметров приёма.
Функция ИзменитьПараметрыПриема (ДокументСсылка, Параметры) Экспорт
	РезультатИзменения = Ложь;
	
	Если НЕ ЗначениеЗаполнено(ДокументСсылка) ИЛИ ТипЗнч(ДокументСсылка) <> Тип("ДокументСсылка.уп_ПредварительнаяЗапись") Тогда
		Возврат РезультатИзменения;
	КонецЕсли;
	
	ДокументОбъект = ДокументСсылка.ПолучитьОбъект();
	Попытка 
		Для Каждого Реквизит Из Параметры Цикл
	//		Если Реквизит.Ключ = "ВремяНачала" Тогда
				
	//		Иначе
				ДокументОбъект[Реквизит.Ключ] = Реквизит.Значение;
				РезультатИзменения = Истина;
	//		КонецЕсли;
		КонецЦикла;
	Исключение
		Возврат Ложь;
	КонецПопытки;
	
	Если РезультатИзменения Тогда
		Попытка
			ДокументОбъект.Записать(РежимЗаписиДокумента.Проведение);
		Исключение
			РезультатИзменения = Ложь;
		КонецПопытки;
	КонецЕсли;
	
	Возврат РезультатИзменения;
КонецФункции
#КонецОбласти
#Область СлужебныеПроцедурыИФункции
//Код процедур и функций
#КонецОбласти

