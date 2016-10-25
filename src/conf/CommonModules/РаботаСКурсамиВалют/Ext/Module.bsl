﻿////////////////////////////////////////////////////////////////////////////////
// Подсистема "Валюты"
// 
////////////////////////////////////////////////////////////////////////////////

#Область ПрограммныйИнтерфейс

// Добавляет в справочник валют валюты из классификатора.
//
// Параметры:
//   Коды - Массив - цифровые коды добавляемых валют.
//
// Возвращаемое значение:
//   Массив, СправочникСсылка.Валюты - ссылки созданных валют.
//
Функция ДобавитьВалютыПоКоду(Знач Коды) Экспорт
	Перем КлассификаторXML, КлассификаторТаблица, ЗаписьОКВ, НоваяСтрока, Результат;
	КлассификаторXML = Справочники.Валюты.ПолучитьМакет("ОбщероссийскийКлассификаторВалют").ПолучитьТекст();
	
	КлассификаторТаблица = ОбщегоНазначения.ПрочитатьXMLВТаблицу(КлассификаторXML).Данные;
	
	Результат = Новый Массив();
	
	Для каждого Код Из Коды Цикл
		ЗаписьОКВ = КлассификаторТаблица.Найти(Код, "Code"); 
		Если ЗаписьОКВ = Неопределено Тогда
			Продолжить;
		КонецЕсли;
		
		ВалютаСсылка = Справочники.Валюты.НайтиПоКоду(ЗаписьОКВ.Code);
		Если ВалютаСсылка.Пустая() Тогда
			НоваяСтрока 						  = Справочники.Валюты.СоздатьЭлемент();
			НоваяСтрока.Код         			  = ЗаписьОКВ.Code;
			НоваяСтрока.Наименование        	  = ЗаписьОКВ.CodeSymbol;
			НоваяСтрока.НаименованиеПолное        = ЗаписьОКВ.Name;
			Если ЗаписьОКВ.RBCLoading Тогда
				НоваяСтрока.СпособУстановкиКурса = Перечисления.СпособыУстановкиКурсаВалюты.ЗагрузкаИзИнтернета;
			Иначе
				НоваяСтрока.СпособУстановкиКурса = Перечисления.СпособыУстановкиКурсаВалюты.РучнойВвод;
			КонецЕсли;
			НоваяСтрока.ПараметрыПрописиНаРусском = ЗаписьОКВ.NumerationItemOptions;
			НоваяСтрока.Записать();
			Результат.Добавить(НоваяСтрока.Ссылка);
		Иначе
			Результат.Добавить(ВалютаСсылка);
		КонецЕсли
	КонецЦикла; 
	
	Возврат	Результат;
	
КонецФункции

// Возвращает курс валюты на дату.
//
// Параметры:
//   Валюта    - СправочникСсылка.Валюты - Валюта, для которой получается курс.
//   ДатаКурса - Дата - Дата, на которую получается курс.
//
// Возвращаемое значение: 
//   Структура - Параметры курса.
//       * Курс      - Число - Курс валюты на указанную дату.
//       * Кратность - Число - Кратность валюты на указанную дату.
//       * Валюта    - СправочникСсылка.Валюты - Ссылка валюты.
//       * ДатаКурса - Дата - Дата получения курса.
//
Функция ПолучитьКурсВалюты(Валюта, ДатаКурса) Экспорт
	
	Результат = РегистрыСведений.КурсыВалют.ПолучитьПоследнее(ДатаКурса, Новый Структура("Валюта", Валюта));
	
	Результат.Вставить("Валюта",    Валюта);
	Результат.Вставить("ДатаКурса", ДатаКурса);
	
	Возврат Результат;
	
КонецФункции

// Формирует представление суммы прописью в указанной валюте.
//
// Параметры:
//   СуммаЧислом - Число - сумма, которую надо представить прописью.
//   Валюта - СправочникСсылка.Валюты - валюта, в которой нужно представить сумму.
//   ВыводитьСуммуБезКопеек - Булево - признак представления суммы без копеек.
//
// Возвращаемое значение:
//   Строка - сумма прописью.
//
Функция СформироватьСуммуПрописью(СуммаЧислом, Валюта, ВыводитьСуммуБезКопеек = Ложь) Экспорт
	
	Сумма             = ?(СуммаЧислом < 0, -СуммаЧислом, СуммаЧислом);
	ПараметрыПредмета = ОбщегоНазначения.ЗначенияРеквизитовОбъекта(Валюта, "ПараметрыПрописиНаРусском");
	
	Результат = ЧислоПрописью(Сумма, "Л=ru_RU;ДП=Ложь", ПараметрыПредмета.ПараметрыПрописиНаРусском);
	
	Если ВыводитьСуммуБезКопеек И Цел(Сумма) = Сумма Тогда
		Результат = Лев(Результат, СтрНайти(Результат, "0") - 1);
	КонецЕсли;
	
	Возврат Результат;
	
КонецФункции

// Пересчитывает сумму из одной валюты в другую.
//
// Параметры:
//  Сумма          - Число - сумма, которую необходимо пересчитать;
//  ИсходнаяВалюта - СправочникСсылка.Валюты - пересчитываемая валюта;
//  НоваяВалюта    - СправочникСсылка.Валюты - валюта, в которую необходимо пересчитать;
//  Дата           - Дата - дата курсов валют.
//
// Возвращаемое значение:
//  Число - пересчитанная сумма.
//
Функция ПересчитатьВВалюту(Сумма, ИсходнаяВалюта, НоваяВалюта, Дата) Экспорт
	
	Возврат РаботаСКурсамиВалютКлиентСервер.ПересчитатьПоКурсу(Сумма,
		ПолучитьКурсВалюты(ИсходнаяВалюта, Дата),
		ПолучитьКурсВалюты(НоваяВалюта, Дата));
		
КонецФункции

// Загружает курсы валют на текущую дату.
//
// Параметры:
//  ПараметрыЗагрузки - Структура - детали загрузки:
//   * НачалоПериода - Дата - начало периода загрузки;
//   * КонецПериода - Дата - конец периода загрузки;
//   * СписокВалют - ТаблицаЗначений - загружаемые валюты:
//     ** Валюта - СправочникСсылка.Валюты;
//     ** КодВалюты - Строка.
//  АдресРезультата - Строка - адрес во временном хранилище для помещения результатов загрузки.
//
Процедура ЗагрузитьАктуальныйКурс(ПараметрыЗагрузки = Неопределено, АдресРезультата = Неопределено) Экспорт
	
	ОбщегоНазначения.ПриНачалеВыполненияРегламентногоЗадания(Метаданные.РегламентныеЗадания.ЗагрузкаКурсовВалют);
	
	ИмяСобытия = НСтр("ru = 'Валюты.Загрузка курсов валют'",
		ОбщегоНазначенияКлиентСервер.КодОсновногоЯзыка());
	
	ЗаписьЖурналаРегистрации(ИмяСобытия, УровеньЖурналаРегистрации.Информация, , ,
		НСтр("ru = 'Начата регламентная загрузка курсов валют'"));
	
	ТекущаяДата = ТекущаяДатаСеанса();
	
	СостояниеЗагрузки = Неопределено;
	ПриЗагрузкеВозниклиОшибки = Ложь;
	
	Если ПараметрыЗагрузки = Неопределено Тогда
		ТекстЗапроса = 
		"ВЫБРАТЬ
		|	КурсыВалют.Валюта КАК Валюта,
		|	КурсыВалют.Валюта.Код КАК КодВалюты,
		|	МАКСИМУМ(КурсыВалют.Период) КАК ДатаКурса
		|ИЗ
		|	РегистрСведений.КурсыВалют КАК КурсыВалют
		|ГДЕ
		|	КурсыВалют.Валюта.СпособУстановкиКурса = ЗНАЧЕНИЕ(Перечисление.СпособыУстановкиКурсаВалюты.ЗагрузкаИзИнтернета)
		|	И НЕ КурсыВалют.Валюта.ПометкаУдаления
		|
		|СГРУППИРОВАТЬ ПО
		|	КурсыВалют.Валюта,
		|	КурсыВалют.Валюта.Код";
		Запрос = Новый Запрос(ТекстЗапроса);
		Выборка = Запрос.Выполнить().Выбрать();
		
		КонецПериода = ТекущаяДата;
		Пока Выборка.Следующий() Цикл
			НачалоПериода = ?(Выборка.ДатаКурса = '198001010000', НачалоГода(ДобавитьМесяц(ТекущаяДата, -12)), Выборка.ДатаКурса + 60*60*24);
			СписокВалют = ОбщегоНазначенияКлиентСервер.ЗначениеВМассиве(Выборка);
			ЗагрузитьКурсыВалютПоПараметрам(СписокВалют, НачалоПериода, КонецПериода, ПриЗагрузкеВозниклиОшибки);
		КонецЦикла;
	Иначе
		Результат = ЗагрузитьКурсыВалютПоПараметрам(ПараметрыЗагрузки.СписокВалют,
			ПараметрыЗагрузки.НачалоПериода, ПараметрыЗагрузки.КонецПериода, ПриЗагрузкеВозниклиОшибки);
	КонецЕсли;
		
	Если АдресРезультата <> Неопределено Тогда
		ПоместитьВоВременноеХранилище(Результат, АдресРезультата);
	КонецЕсли;

	Если ПриЗагрузкеВозниклиОшибки Тогда
		ЗаписьЖурналаРегистрации(
			ИмяСобытия,
			УровеньЖурналаРегистрации.Ошибка,
			, 
			,
			НСтр("ru = 'Во время регламентного задания загрузки курсов валют возникли ошибки'"));
		ВызватьИсключение НСтр("ru = 'Загрузка курсов не выполнена. Подробности см. в журнале регистрации.'");
	Иначе
		ЗаписьЖурналаРегистрации(
			ИмяСобытия,
			УровеньЖурналаРегистрации.Информация,
			,
			,
			НСтр("ru = 'Завершена регламентная загрузка курсов валют.'"));
	КонецЕсли;
	
КонецПроцедуры

#КонецОбласти

#Область СлужебныйПрограммныйИнтерфейс

// См. описание этой же процедуры в модуле СтандартныеПодсистемыСервер.
Процедура ПриДобавленииОбработчиковСлужебныхСобытий(КлиентскиеОбработчики, СерверныеОбработчики) Экспорт
	
	// КЛИЕНТСКИЕ ОБРАБОТЧИКИ.
	
	КлиентскиеОбработчики["СтандартныеПодсистемы.БазоваяФункциональность\ПослеНачалаРаботыСистемы"].Добавить(
		"РаботаСКурсамиВалютКлиент");
	
	// СЕРВЕРНЫЕ ОБРАБОТЧИКИ.
	
	СерверныеОбработчики["СтандартныеПодсистемы.ОбновлениеВерсииИБ\ПриДобавленииОбработчиковОбновления"].Добавить(
		"РаботаСКурсамиВалют");
	
	СерверныеОбработчики["СтандартныеПодсистемы.БазоваяФункциональность\ПриДобавленииИсключенийПоискаСсылок"].Добавить(
		"РаботаСКурсамиВалют");
	
	СерверныеОбработчики["СтандартныеПодсистемы.БазоваяФункциональность\ПриДобавленииПараметровРаботыКлиентаПриЗапуске"].Добавить(
		"РаботаСКурсамиВалют");
	
	Если ОбщегоНазначения.ПодсистемаСуществует("СтандартныеПодсистемы.ТекущиеДела") Тогда
		СерверныеОбработчики["СтандартныеПодсистемы.ТекущиеДела\ПриЗаполненииСпискаТекущихДел"].Добавить(
			"РаботаСКурсамиВалют");
	КонецЕсли;
	
	СерверныеОбработчики["СтандартныеПодсистемы.БазоваяФункциональность\ПриЗаполненииРазрешенийНаДоступКВнешнимРесурсам"].Добавить(
		"РаботаСКурсамиВалют");
	
КонецПроцедуры

// Заполняет список текущих дел пользователя.
//
// Параметры:
//  ТекущиеДела - ТаблицаЗначений - таблица значений с колонками:
//    * Идентификатор - Строка - внутренний идентификатор дела, используемый механизмом "Текущие дела".
//    * ЕстьДела      - Булево - если Истина, дело выводится в списке текущих дел пользователя.
//    * Важное        - Булево - если Истина, дело будет выделено красным цветом.
//    * Представление - Строка - представление дела, выводимое пользователю.
//    * Количество    - Число  - количественный показатель дела, выводится в строке заголовка дела.
//    * Форма         - Строка - полный путь к форме, которую необходимо открыть при нажатии на гиперссылку
//                               дела на панели "Текущие дела".
//    * ПараметрыФормы- Структура - параметры, с которыми нужно открывать форму показателя.
//    * Владелец      - Строка, объект метаданных - строковый идентификатор дела, которое будет владельцем для текущего
//                      или объект метаданных подсистема.
//    * Подсказка     - Строка - текст подсказки.
//
Процедура ПриЗаполненииСпискаТекущихДел(ТекущиеДела) Экспорт
	
	МодульТекущиеДелаСервер = ОбщегоНазначения.ОбщийМодуль("ТекущиеДелаСервер");
	Если ОбщегоНазначенияПовтИсп.РазделениеВключено() // В модели сервиса обновляется автоматически.
		Или ОбщегоНазначенияПовтИсп.ЭтоАвтономноеРабочееМесто()
		Или Не ПравоДоступа("Изменение", Метаданные.РегистрыСведений.КурсыВалют)
		Или МодульТекущиеДелаСервер.ДелоОтключено("КлассификаторВалют") Тогда
		Возврат;
	КонецЕсли;
	
	КурсыАктуальны = КурсыАктуальны();
	
	// Процедура вызывается только при наличии подсистемы "Текущие дела", поэтому здесь
	// не делается проверка существования подсистемы.
	Разделы = МодульТекущиеДелаСервер.РазделыДляОбъекта(Метаданные.Справочники.Валюты.ПолноеИмя());
	
	Для Каждого Раздел Из Разделы Цикл
		
		ИдентификаторВалюты = "КлассификаторВалют" + СтрЗаменить(Раздел.ПолноеИмя(), ".", "");
		Дело = ТекущиеДела.Добавить();
		Дело.Идентификатор  = ИдентификаторВалюты;
		Дело.ЕстьДела       = Не КурсыАктуальны;
		Дело.Представление  = НСтр("ru = 'Курсы валют устарели'");
		Дело.Важное         = Истина;
		Дело.Форма          = "Обработка.ЗагрузкаКурсовВалют.Форма";
		Дело.ПараметрыФормы = Новый Структура("ОткрытиеИзСписка", Истина);
		Дело.Владелец       = Раздел;
		
	КонецЦикла;
	
КонецПроцедуры

// Определить список справочников, доступных для загрузки с помощью подсистемы "Загрузка данных из файла".
//
// Параметры:
//  Обработчики - ТаблицаЗначений - список справочников, в которые возможна загрузка данных.
//      * ПолноеИмя          - Строка - полное имя справочника (как в метаданных).
//      * Представление      - Строка - представление справочника в списке выбора.
//      * ПрикладнаяЗагрузка - Булево - если Истина, значит справочник использует собственный алгоритм загрузки и
//                                      в модуле менеджера справочника определены функции.
//
Процедура ПриОпределенииСправочниковДляЗагрузкиДанных(ЗагружаемыеСправочники) Экспорт
	
	// Загрузка в классификатор валюты запрещена.
	СтрокаТаблицы = ЗагружаемыеСправочники.Найти(Метаданные.Справочники.Валюты.ПолноеИмя(), "ПолноеИмя");
	Если СтрокаТаблицы <> Неопределено Тогда 
		ЗагружаемыеСправочники.Удалить(СтрокаТаблицы);
	КонецЕсли;
	
КонецПроцедуры

// Определить объекты метаданных, в модулях менеджеров которых ограничивается возможность 
// редактирования реквизитов при групповом изменении.
//
// Параметры:
//   Объекты - Соответствие - в качестве ключа указать полное имя объекта метаданных,
//                            подключенного к подсистеме "Групповое изменение объектов". 
//                            Дополнительно в значении могут быть перечислены имена экспортных функций:
//                            "РеквизитыНеРедактируемыеВГрупповойОбработке",
//                            "РеквизитыРедактируемыеВГрупповойОбработке".
//                            Каждое имя должно начинаться с новой строки.
//                            Если указана пустая строка, значит в модуле менеджера определены обе функции.
//
Процедура ПриОпределенииОбъектовСРедактируемымиРеквизитами(Объекты) Экспорт
	Объекты.Вставить(Метаданные.Справочники.Валюты.ПолноеИмя(), "РеквизитыРедактируемыеВГрупповойОбработке");
КонецПроцедуры

////////////////////////////////////////////////////////////////////////////////
// Обработчики условных вызовов в эту подсистему.

// См. описание одноименной процедуры в общем модуле РегламентныеЗаданияПереопределяемый.
//
Процедура ПриОпределенииНастроекРегламентныхЗаданий(Зависимости) Экспорт
	Зависимость = Зависимости.Добавить();
	Зависимость.РегламентноеЗадание = Метаданные.РегламентныеЗадания.ЗагрузкаКурсовВалют;
	Зависимость.ДоступноВМоделиСервиса = Ложь;
	Зависимость.ДоступноВАвтономномРабочемМесте = Ложь;
КонецПроцедуры

// См. одноименную процедуру в общем модуле ПользователиПереопределяемый.
Процедура ПриОпределенииНазначенияРолей(НазначениеРолей) Экспорт
	
	// СовместноДляПользователейИВнешнихПользователей.
	НазначениеРолей.СовместноДляПользователейИВнешнихПользователей.Добавить(
		Метаданные.Роли.ЧтениеКурсовВалют.Имя);
	
КонецПроцедуры

#КонецОбласти

#Область СлужебныеПроцедурыИФункции

////////////////////////////////////////////////////////////////////////////////
// Обработчики служебных событий подсистем БСП.

// Заполняет параметры, которые используется клиентским кодом на запуске конфигурации.
//
// Параметры:
//   Параметры - Структура - Параметры запуска.
//
Процедура ПриДобавленииПараметровРаботыКлиентаПриЗапуске(Параметры) Экспорт
	
	Если ОбщегоНазначенияПовтИсп.РазделениеВключено() Или ОбщегоНазначенияПовтИсп.ЭтоАвтономноеРабочееМесто() Тогда
		КурсыОбновляютсяОтветственными = Ложь; // В модели сервиса обновляются автоматически.
	ИначеЕсли НЕ ПравоДоступа("Изменение", Метаданные.РегистрыСведений.КурсыВалют) Тогда
		КурсыОбновляютсяОтветственными = Ложь; // Пользователь не может обновлять курсы валют.
	Иначе
		КурсыОбновляютсяОтветственными = КурсыЗагружаютсяИзИнтернета(); // Есть валюты, для которых можно загружать курсы.
	КонецЕсли;
	
	ВключитьОповещение = Не ОбщегоНазначения.ПодсистемаСуществует("СтандартныеПодсистемы.ТекущиеДела");
	РаботаСКурсамиВалютПереопределяемый.ПриОпределенииНеобходимостиПоказаПредупрежденияОбУстаревшихКурсахВалют(ВключитьОповещение);
	
	Параметры.Вставить("Валюты", Новый ФиксированнаяСтруктура("КурсыОбновляютсяОтветственными", (КурсыОбновляютсяОтветственными И ВключитьОповещение)));
	
КонецПроцедуры

// Заполняет массив списком имен объектов метаданных, данные которых могут содержать ссылки на различные объекты
// метаданных, но при этом эти ссылки не должны учитываться в бизнес-логике приложения.
//
// Параметры:
//  Массив - массив строк, например, "РегистрСведений.ВерсииОбъектов".
//
Процедура ПриДобавленииИсключенийПоискаСсылок(Массив) Экспорт
	
	Массив.Добавить(Метаданные.РегистрыСведений.КурсыВалют.ПолноеИмя());
	
КонецПроцедуры

// Заполняет перечень запросов внешних разрешений, которые обязательно должны быть предоставлены
// при создании информационной базы или обновлении программы.
//
// Параметры:
//  ЗапросыРазрешений - Массив - список значений, возвращенных функцией.
//                      РаботаВБезопасномРежиме.ЗапросНаИспользованиеВнешнихРесурсов().
//
Процедура ПриЗаполненииРазрешенийНаДоступКВнешнимРесурсам(ЗапросыРазрешений) Экспорт
	
	Если ОбщегоНазначенияПовтИсп.РазделениеВключено() Тогда
		Возврат;
	КонецЕсли;
	
	ЗапросыРазрешений.Добавить(
		РаботаВБезопасномРежиме.ЗапросНаИспользованиеВнешнихРесурсов(Разрешения()));
	
КонецПроцедуры

// Возвращает список разрешений для загрузки курсов валют с сайта РБК.
//
// Возвращаемое значение:
//  Массив.
//
Функция Разрешения()
	
	Протокол = "HTTP";
	Адрес = "cbrates.rbc.ru";
	Порт = Неопределено;
	Описание = НСтр("ru = 'Загрузка курсов валют из Интернета.'");
	
	Разрешения = Новый Массив;
	Разрешения.Добавить( 
		РаботаВБезопасномРежиме.РазрешениеНаИспользованиеИнтернетРесурса(Протокол, Адрес, Порт, Описание));
	
	Возврат Разрешения;
	
КонецФункции

////////////////////////////////////////////////////////////////////////////////
// Экспортные служебные процедуры и функции.

// Проверяет наличие установленного курса и кратности валюты на 1 января 1980 года.
// В случае отсутствия устанавливает курс и кратность равными единице.
//
// Параметры:
//  Валюта - ссылка на элемент справочника Валют.
//
Процедура ПроверитьКорректностьКурсаНа01_01_1980(Валюта) Экспорт
	ДатаКурса1980 = '198001010000';
	
	ТекстЗапроса =
	"ВЫБРАТЬ
	|	1 КАК Количество
	|ИЗ
	|	РегистрСведений.КурсыВалют КАК КурсыВалют
	|ГДЕ
	|	КурсыВалют.Валюта = &Валюта
	|	И КурсыВалют.Период = &Период";
	
	Запрос = Новый Запрос(ТекстЗапроса);
	Запрос.УстановитьПараметр("Валюта", Валюта);
	Запрос.УстановитьПараметр("Период", ДатаКурса1980);
	РезультатЗапроса = Запрос.Выполнить();
	Если РезультатЗапроса.Пустой() Тогда
		НаборЗаписей = РегистрыСведений.КурсыВалют.СоздатьНаборЗаписей();
		НаборЗаписей.Отбор.Валюта.Установить(Валюта);
		Запись = НаборЗаписей.Добавить();
		Запись.Валюта = Валюта;
		Запись.Период = ДатаКурса1980;
		Запись.Курс = 1;
		Запись.Кратность = 1;
		НаборЗаписей.ДополнительныеСвойства.Вставить("ПропуститьПроверкуЗапретаИзменения");
		НаборЗаписей.Записать(Ложь);
	КонецЕсли;
КонецПроцедуры

// Возвращает массив валют, курсы которых загружаются с сайта РБК.
//
Функция ЗагружаемыеВалюты() Экспорт
	
	Запрос = Новый Запрос;
	Запрос.Текст = 
	"ВЫБРАТЬ
	|	Валюты.Ссылка КАК Ссылка
	|ИЗ
	|	Справочник.Валюты КАК Валюты
	|ГДЕ
	|	Валюты.СпособУстановкиКурса = ЗНАЧЕНИЕ(Перечисление.СпособыУстановкиКурсаВалюты.ЗагрузкаИзИнтернета)
	|	И НЕ Валюты.ПометкаУдаления
	|
	|УПОРЯДОЧИТЬ ПО
	|	Валюты.НаименованиеПолное";

	Возврат Запрос.Выполнить().Выгрузить().ВыгрузитьКолонку("Ссылка");
	
КонецФункции

// Возвращает информацию о курсе валюты на основе ссылки на валюту.
// Данные возвращаются в виде структуры.
//
// Параметры:
// ВыбраннаяВалюта - Справочник.Валюты / Ссылка - ссылка на валюту, информацию
//                  о курсе которой необходимо получить.
//
// Возвращаемое значение:
// ДанныеКурса   - структура, содержащая информацию о последней доступной 
//                 записи курса.
//
Функция ЗаполнитьДанныеКурсаДляВалюты(ВыбраннаяВалюта) Экспорт
	
	ДанныеКурса = Новый Структура("ДатаКурса, Курс, Кратность");
	
	Запрос = Новый Запрос;
	
	Запрос.Текст = "ВЫБРАТЬ РегКурсы.Период, РегКурсы.Курс, РегКурсы.Кратность
	              | ИЗ РегистрСведений.КурсыВалют.СрезПоследних(&ОкончаниеПериодаЗагрузки, Валюта = &ВыбраннаяВалюта) КАК РегКурсы";
	Запрос.УстановитьПараметр("ВыбраннаяВалюта", ВыбраннаяВалюта);
	Запрос.УстановитьПараметр("ОкончаниеПериодаЗагрузки", ТекущаяДатаСеанса());
	
	ВыборкаКурс = Запрос.Выполнить().Выбрать();
	ВыборкаКурс.Следующий();
	
	ДанныеКурса.ДатаКурса = ВыборкаКурс.Период;
	ДанныеКурса.Курс      = ВыборкаКурс.Курс;
	ДанныеКурса.Кратность = ВыборкаКурс.Кратность;
	
	Возврат ДанныеКурса;
	
КонецФункции

// Возвращает таблицу значений - валюты, зависящие от переданной
// в качестве параметра.
// Возвращаемое значение
// ТаблицаЗначений
// колонка "Ссылка" - СправочникСсылка.Валюты
// колонка "Наценка" - число.
//
Функция СписокЗависимыхВалют(ВалютаБазовая, ДополнительныеСвойства = Неопределено) Экспорт
	
	Кэшировать = (ТипЗнч(ДополнительныеСвойства) = Тип("Структура"));
	
	Если Кэшировать Тогда
		
		ЗависимыеВалюты = ДополнительныеСвойства.ЗависимыеВалюты.Получить(ВалютаБазовая);
		
		Если ТипЗнч(ЗависимыеВалюты) = Тип("ТаблицаЗначений") Тогда
			Возврат ЗависимыеВалюты;
		КонецЕсли;
		
	КонецЕсли;
	
	Запрос = Новый Запрос;
	Запрос.Текст = 
	"ВЫБРАТЬ
	|	СпрВалюты.Ссылка,
	|	СпрВалюты.Наценка,
	|	СпрВалюты.СпособУстановкиКурса,
	|	СпрВалюты.ФормулаРасчетаКурса
	|ИЗ
	|	Справочник.Валюты КАК СпрВалюты
	|ГДЕ
	|	СпрВалюты.ОсновнаяВалюта = &ВалютаБазовая
	|
	|ОБЪЕДИНИТЬ ВСЕ
	|
	|ВЫБРАТЬ
	|	СпрВалюты.Ссылка,
	|	СпрВалюты.Наценка,
	|	СпрВалюты.СпособУстановкиКурса,
	|	СпрВалюты.ФормулаРасчетаКурса
	|ИЗ
	|	Справочник.Валюты КАК СпрВалюты
	|ГДЕ
	|	СпрВалюты.ФормулаРасчетаКурса ПОДОБНО &СимвольныйКод";
	
	Запрос.УстановитьПараметр("ВалютаБазовая", ВалютаБазовая);
	Запрос.УстановитьПараметр("СимвольныйКод", "%" + ОбщегоНазначения.ЗначениеРеквизитаОбъекта(ВалютаБазовая, "Наименование") + "%");
	
	ЗависимыеВалюты = Запрос.Выполнить().Выгрузить();
	
	Если Кэшировать Тогда
		
		ДополнительныеСвойства.ЗависимыеВалюты.Вставить(ВалютаБазовая, ЗависимыеВалюты);
		
	КонецЕсли;
	
	Возврат ЗависимыеВалюты;
	
КонецФункции

Процедура ОбновитьКурсВалюты(Параметры, АдресРезультата) Экспорт
	
	ПодчиненнаяВалюта    = Параметры.ПодчиненнаяВалюта;
	СпособУстановкиКурса = Параметры.СпособУстановкиКурса;
	
	НачатьТранзакцию();
	Попытка
		Блокировка = Новый БлокировкаДанных;
		ЭлементБлокировки = Блокировка.Добавить("Справочник.Валюты");
		ЭлементБлокировки.УстановитьЗначение("Ссылка", ПодчиненнаяВалюта.Ссылка);
		ЭлементБлокировки.Режим = РежимБлокировкиДанных.Исключительный;
		Блокировка.Заблокировать();
		ЗафиксироватьТранзакцию();
	Исключение
		ОтменитьТранзакцию();
		ВызватьИсключение;
	КонецПопытки;
	
	Если СпособУстановкиКурса = Перечисления.СпособыУстановкиКурсаВалюты.НаценкаНаКурсДругойВалюты Тогда
		Запрос = Новый Запрос;
		Запрос.Текст = 
		"ВЫБРАТЬ
		|	КурсыВалют.Период,
		|	КурсыВалют.Валюта,
		|	КурсыВалют.Курс,
		|	КурсыВалют.Кратность
		|ИЗ
		|	РегистрСведений.КурсыВалют КАК КурсыВалют
		|ГДЕ
		|	КурсыВалют.Валюта = &ВалютаИсточник";
		Запрос.УстановитьПараметр("ВалютаИсточник", ПодчиненнаяВалюта.ОсновнаяВалюта);
		
		Выборка = Запрос.Выполнить().Выбрать();
		
		НаборЗаписей = РегистрыСведений.КурсыВалют.СоздатьНаборЗаписей();
		НаборЗаписей.Отбор.Валюта.Установить(ПодчиненнаяВалюта.Ссылка);
		
		Наценка = ПодчиненнаяВалюта.Наценка;
		
		Пока Выборка.Следующий() Цикл
			
			НоваяЗаписьНабораКурсов = НаборЗаписей.Добавить();
			НоваяЗаписьНабораКурсов.Валюта    = ПодчиненнаяВалюта.Ссылка;
			НоваяЗаписьНабораКурсов.Кратность = Выборка.Кратность;
			НоваяЗаписьНабораКурсов.Курс      = Выборка.Курс + Выборка.Курс * Наценка / 100;
			НоваяЗаписьНабораКурсов.Период    = Выборка.Период;
			
		КонецЦикла;
		
		НаборЗаписей.ДополнительныеСвойства.Вставить("ОтключитьКонтрольПодчиненныхВалют");
		Если ПодчиненнаяВалюта.ДополнительныеСвойства.Свойство("ЭтоНовый") Тогда
			НаборЗаписей.ДополнительныеСвойства.Вставить("ПропуститьПроверкуЗапретаИзменения");
		КонецЕсли;

		НаборЗаписей.Записать();
		
	ИначеЕсли СпособУстановкиКурса = Перечисления.СпособыУстановкиКурсаВалюты.РасчетПоФормуле Тогда
		
		// Получить основные валюты для ПодчиненнаяВалюта.
		Запрос = Новый Запрос;
		Запрос.Текст = 
		"ВЫБРАТЬ
		|	Валюты.Ссылка КАК Ссылка
		|ИЗ
		|	Справочник.Валюты КАК Валюты
		|ГДЕ
		|	&ФормулаРасчетаКурса ПОДОБНО ""%"" + Валюты.Наименование + ""%""";
		
		Запрос.УстановитьПараметр("ФормулаРасчетаКурса", ПодчиненнаяВалюта.ФормулаРасчетаКурса);
		ОсновныеВалюты = Запрос.Выполнить().Выгрузить();
		
		Если ОсновныеВалюты.Количество() = 0 Тогда
			ТекстОшибки = НСтр("ru = 'В формуле должна быть использована хотя бы одна основная валюта.'");
			ОбщегоНазначенияКлиентСервер.СообщитьПользователю(ТекстОшибки, , "Объект.ФормулаРасчетаКурса");
			ВызватьИсключение ТекстОшибки;
		КонецЕсли;
		
		ОбновленныеПериоды = Новый Соответствие; // Кэш для однократного пересчета курса за один и тот же период.
		// Перезаписать курсы основных валют для обновления курса валюты ПодчиненнаяВалюта.
		Для каждого ЗаписьОсновнойВалюты Из ОсновныеВалюты Цикл
			НаборЗаписей = РегистрыСведений.КурсыВалют.СоздатьНаборЗаписей();
			НаборЗаписей.Отбор.Валюта.Установить(ЗаписьОсновнойВалюты.Ссылка);
			НаборЗаписей.Прочитать();
			НаборЗаписей.ДополнительныеСвойства.Вставить("ОбновитьКурсЗависимойВалюты", ПодчиненнаяВалюта.Ссылка);
			НаборЗаписей.ДополнительныеСвойства.Вставить("ОбновленныеПериоды", ОбновленныеПериоды);
			
			Если ПодчиненнаяВалюта.ДополнительныеСвойства.Свойство("ЭтоНовый") Тогда
				НаборЗаписей.ДополнительныеСвойства.Вставить("ПропуститьПроверкуЗапретаИзменения");
			КонецЕсли;
			
			НаборЗаписей.Записать();
		КонецЦикла
		
	КонецЕсли;
	
КонецПроцедуры

////////////////////////////////////////////////////////////////////////////////
// Обновление информационной базы.

// Добавляет процедуры-обработчики обновления, необходимые данной подсистеме.
//
// Параметры:
//  Обработчики - ТаблицаЗначений - см. описание функции НоваяТаблицаОбработчиковОбновления
//                                  общего модуля ОбновлениеИнформационнойБазы.
// 
Процедура ПриДобавленииОбработчиковОбновления(Обработчики) Экспорт
	
	Обработчик = Обработчики.Добавить();
	Обработчик.Версия = "1.0.5.9";
	Обработчик.Процедура = "РаботаСКурсамиВалют.ОбновитьФорматХраненияПрописиНаРусскомЯзыке";
	
	Обработчик = Обработчики.Добавить();
	Обработчик.Версия = "2.1.4.4";
	Обработчик.Процедура = "РаботаСКурсамиВалют.ОбновитьСведенияОВалюте937";
	Обработчик.РежимВыполнения = "Монопольно";
	
	Обработчик = Обработчики.Добавить();
	Обработчик.Версия = "2.2.3.10";
	Обработчик.Процедура = "РаботаСКурсамиВалют.ЗаполнитьСпособУстановкиКурсаВалют";
	Обработчик.РежимВыполнения = "Монопольно";
	
	Обработчик = Обработчики.Добавить();
	Обработчик.Версия = "2.3.3.76";
	Обработчик.Процедура = "Справочники.Валюты.ОтключитьЗагрузкуКурсаВалюты643ИзИнтернета";
	Обработчик.РежимВыполнения = "Отложенно";
	Обработчик.Идентификатор = Новый УникальныйИдентификатор("dc79c561-8657-4852-bbc5-38ced6996fff");
	Обработчик.Комментарий = НСтр("ru = 'Отключает ошибочно включенную загрузку курсов валюты ""Российский рубль (643)"" из интернета.'");
	Обработчик.ОчередьОтложеннойОбработки = 1;
	Обработчик.ПроцедураЗаполненияДанныхОбновления = "Справочники.Валюты.ЗарегистрироватьДанныеКОбработкеДляПереходаНаНовуюВерсию";
	Обработчик.ЧитаемыеОбъекты      = "Справочник.Валюты";
	Обработчик.ИзменяемыеОбъекты    = "Справочник.Валюты";
	
КонецПроцедуры

// Обработчик обновления формата хранения прописей при переходе на более новую версию БСП.
//
Процедура ОбновитьФорматХраненияПрописиНаРусскомЯзыке() Экспорт
	
	ВыборкаВалют = Справочники.Валюты.Выбрать();
	
	Пока ВыборкаВалют.Следующий() Цикл
		Объект = ВыборкаВалют.ПолучитьОбъект();
		СтрокаПараметров = СтрЗаменить(Объект.ПараметрыПрописиНаРусском, ",", Символы.ПС);
		Род1 = НРег(Лев(СокрЛП(СтрПолучитьСтроку(СтрокаПараметров, 4)), 1));
		Род2 = НРег(Лев(СокрЛП(СтрПолучитьСтроку(СтрокаПараметров, 8)), 1));
		Объект.ПараметрыПрописиНаРусском = 
					  СокрЛП(СтрПолучитьСтроку(СтрокаПараметров, 1)) + ", "
					+ СокрЛП(СтрПолучитьСтроку(СтрокаПараметров, 2)) + ", "
					+ СокрЛП(СтрПолучитьСтроку(СтрокаПараметров, 3)) + ", "
					+ Род1 + ", "
					+ СокрЛП(СтрПолучитьСтроку(СтрокаПараметров, 5)) + ", "
					+ СокрЛП(СтрПолучитьСтроку(СтрокаПараметров, 6)) + ", "
					+ СокрЛП(СтрПолучитьСтроку(СтрокаПараметров, 7)) + ", "
					+ Род2 + ", "
					+ СокрЛП(СтрПолучитьСтроку(СтрокаПараметров, 9));
		ОбновлениеИнформационнойБазы.ЗаписатьДанные(Объект);
	КонецЦикла;
	
КонецПроцедуры

// Обновляет сведения о валюте, согласно документу "Изменение 33/2012 ОКВ Общероссийский классификатор валют.
// ОК (МК (ИСО 4217) 003-97) 014-2000" (принято и введено в действие Приказом Росстандарта от 12.12.2012 N 1883-ст).
//
Процедура ОбновитьСведенияОВалюте937() Экспорт
	Валюта = Справочники.Валюты.НайтиПоКоду("937");
	Если Не Валюта.Пустая() Тогда
		Валюта = Валюта.ПолучитьОбъект();
		Валюта.Наименование = "VEF";
		Валюта.НаименованиеПолное = НСтр("ru = 'Боливар'");
		ОбновлениеИнформационнойБазы.ЗаписатьДанные(Валюта);
	КонецЕсли;
КонецПроцедуры

// Заполняет реквизит СпособУстановкиКурса у элементов справочника Валюты.
Процедура ЗаполнитьСпособУстановкиКурсаВалют() Экспорт
	Выборка = Справочники.Валюты.Выбрать();
	Пока Выборка.Следующий() Цикл
		Валюта = Выборка.Ссылка.ПолучитьОбъект();
		Если Валюта.ЗагружаетсяИзИнтернета Тогда
			Валюта.СпособУстановкиКурса = Перечисления.СпособыУстановкиКурсаВалюты.ЗагрузкаИзИнтернета;
		ИначеЕсли Не Валюта.ОсновнаяВалюта.Пустая() Тогда
			Валюта.СпособУстановкиКурса = Перечисления.СпособыУстановкиКурсаВалюты.НаценкаНаКурсДругойВалюты;
		Иначе
			Валюта.СпособУстановкиКурса = Перечисления.СпособыУстановкиКурсаВалюты.РучнойВвод;
		КонецЕсли;
		Валюта.Записать();
	КонецЦикла;
КонецПроцедуры

////////////////////////////////////////////////////////////////////////////////
// Обновление курсов валют

// Проверяет актуальность курсов всех валют.
//
Функция КурсыАктуальны() Экспорт
	ТекстЗапроса =
	"ВЫБРАТЬ
	|	Валюты.Ссылка КАК Ссылка
	|ПОМЕСТИТЬ втВалюты
	|ИЗ
	|	Справочник.Валюты КАК Валюты
	|ГДЕ
	|	Валюты.СпособУстановкиКурса = ЗНАЧЕНИЕ(Перечисление.СпособыУстановкиКурсаВалюты.ЗагрузкаИзИнтернета)
	|	И Валюты.ПометкаУдаления = ЛОЖЬ
	|;
	|
	|////////////////////////////////////////////////////////////////////////////////
	|ВЫБРАТЬ ПЕРВЫЕ 1
	|	1 КАК Поле1
	|ИЗ
	|	втВалюты КАК Валюты
	|		ЛЕВОЕ СОЕДИНЕНИЕ РегистрСведений.КурсыВалют КАК КурсыВалют
	|		ПО Валюты.Ссылка = КурсыВалют.Валюта
	|			И (КурсыВалют.Период = &ТекущаяДата)
	|ГДЕ
	|	КурсыВалют.Валюта ЕСТЬ NULL ";
	
	Запрос = Новый Запрос;
	Запрос.УстановитьПараметр("ТекущаяДата", НачалоДня(ТекущаяДатаСеанса()));
	Запрос.Текст = ТекстЗапроса;
	
	Возврат Запрос.Выполнить().Пустой();
КонецФункции

// Определяет есть ли хоть одна валюта, курс которой может загружаться из сети Интернет.
//
Функция КурсыЗагружаютсяИзИнтернета()
	Запрос = Новый Запрос;
	Запрос.Текст =
	"ВЫБРАТЬ ПЕРВЫЕ 1
	|	1 КАК Поле1
	|ИЗ
	|	Справочник.Валюты КАК Валюты
	|ГДЕ
	|	Валюты.СпособУстановкиКурса = ЗНАЧЕНИЕ(Перечисление.СпособыУстановкиКурсаВалюты.ЗагрузкаИзИнтернета)
	|	И Валюты.ПометкаУдаления = ЛОЖЬ";
	Возврат НЕ Запрос.Выполнить().Пустой();
КонецФункции

// Процедура для загрузки курсов валют по определенному периоду.
//
// Параметры:
// Валюты		- Любая коллекция - со следующими полями:
//					КодВалюты - числовой код валюты.
//					Валюта - ссылка на валюту.
// НачалоПериодаЗагрузки	- Дата - начало периода загрузки курсов.
// ОкончаниеПериодаЗагрузки	- Дата - окончание периода загрузки курсов.
//
// Возвращаемое значение:
// Массив состояния загрузки  - каждый элемент - структура с полями.
//		Валюта - загружаемая валюта.
//		СтатусОперации - завершилась ли загрузка успешно.
//		Сообщение - пояснение о загрузке (текст сообщения об ошибке или поясняющее сообщение).
//
Функция ЗагрузитьКурсыВалютПоПараметрам(Знач Валюты, Знач НачалоПериодаЗагрузки, Знач ОкончаниеПериодаЗагрузки, 
	ПриЗагрузкеВозниклиОшибки = Ложь)
	
	СостояниеЗагрузки = Новый Массив;
	
	ПриЗагрузкеВозниклиОшибки = Ложь;
	
	СерверИсточник = "cbrates.rbc.ru";
	
	Если НачалоПериодаЗагрузки = ОкончаниеПериодаЗагрузки Тогда
		Адрес = "tsv/";
		ТМП   = Формат(ОкончаниеПериодаЗагрузки, "ДФ=/yyyy/MM/dd"); // Не локализуется - путь к файлу на сервере.
	Иначе
		Адрес = "tsv/cb/";
		ТМП   = "";
	КонецЕсли;
	
	Для Каждого Валюта Из Валюты Цикл
		ФайлНаВебСервере = "http://" + СерверИсточник + "/" + Адрес + Прав(Валюта.КодВалюты, 3) + ТМП + ".tsv";
		Результат = ПолучениеФайловИзИнтернета.СкачатьФайлНаСервере(ФайлНаВебСервере);
		
		Если Результат.Статус Тогда
			ПоясняющееСообщение = ЗагрузитьКурсВалютыИзФайла(Валюта.Валюта, Результат.Путь, НачалоПериодаЗагрузки, ОкончаниеПериодаЗагрузки) + Символы.ПС;
			УдалитьФайлы(Результат.Путь);
			СтатусОперации = ПустаяСтрока(ПоясняющееСообщение);
		Иначе
			ПоясняющееСообщение = СтроковыеФункцииКлиентСервер.ПодставитьПараметрыВСтроку(
				НСтр("ru = 'Невозможно получить файл данных с курсами валюты (%1 - %2):
					|%3
					|Возможно, нет доступа к веб сайту с курсами валют, либо указана несуществующая валюта.'"),
				Валюта.КодВалюты,
				Валюта.Валюта,
				Результат.СообщениеОбОшибке);
			СтатусОперации = Ложь;
			ПриЗагрузкеВозниклиОшибки = Истина;
		КонецЕсли;
		
		СостояниеЗагрузки.Добавить(Новый Структура("Валюта,СтатусОперации,Сообщение", Валюта.Валюта, СтатусОперации, ПоясняющееСообщение));
		
	КонецЦикла;
	
	Возврат СостояниеЗагрузки;
	
КонецФункции

// Загружает информацию о курсе валюты Валюта из файла ПутьКФайлу в регистр
// сведений курсов валют. При этом файл с курсами разбирается, и записываются
// только те данные, которые удовлетворяют периоду (НачалоПериодаЗагрузки, ОкончаниеПериодаЗагрузки).
//
Функция ЗагрузитьКурсВалютыИзФайла(Знач Валюта, Знач ПутьКФайлу, Знач НачалоПериодаЗагрузки, Знач ОкончаниеПериодаЗагрузки)
	
	СтатусЗагрузки = 1;
	
	ЧислоЗагружаемыхДнейВсего = 1 + (ОкончаниеПериодаЗагрузки - НачалоПериодаЗагрузки) / ( 24 * 60 * 60);
	
	ЧислоЗагруженныхДней = 0;
	
	Если ЭтоАдресВременногоХранилища(ПутьКФайлу) Тогда
		ИмяФайла = ПолучитьИмяВременногоФайла();
		ДвоичныеДанные = ПолучитьИзВременногоХранилища(ПутьКФайлу);
		ДвоичныеДанные.Записать(ИмяФайла);
	Иначе
		ИмяФайла = ПутьКФайлу;
	КонецЕсли;
	
	Текст = Новый ТекстовыйДокумент();
	
	
	Текст.Прочитать(ИмяФайла, КодировкаТекста.ANSI);
	
	ДатаЗапрета = Неопределено;
	Для НомерСтроки = 1 По Текст.КоличествоСтрок() Цикл
		
		Стр = Текст.ПолучитьСтроку(НомерСтроки);
		Если (Стр = "") ИЛИ (СтрНайти(Стр, Символы.Таб) = 0) Тогда
			Продолжить;
		КонецЕсли;
		
		Если НачалоПериодаЗагрузки = ОкончаниеПериодаЗагрузки Тогда
			ДатаКурса = ОкончаниеПериодаЗагрузки;
		Иначе
			ДатаКурсаСтр = ВыделитьПодСтроку(Стр);
			ДатаКурса = Дата(Лев(ДатаКурсаСтр,4), Сред(ДатаКурсаСтр,5,2), Сред(ДатаКурсаСтр,7,2));
		КонецЕсли;
		
		Кратность = Число(ВыделитьПодСтроку(Стр));
		Курс = Число(ВыделитьПодСтроку(Стр));
		
		Если ДатаКурса > ОкончаниеПериодаЗагрузки Тогда
			Прервать;
		КонецЕсли;
		
		Если ДатаКурса < НачалоПериодаЗагрузки Тогда 
			Продолжить;
		КонецЕсли;
		
		НаборЗаписей = РегистрыСведений.КурсыВалют.СоздатьНаборЗаписей();
		НаборЗаписей.Отбор.Валюта.Установить(Валюта);
		НаборЗаписей.Отбор.Период.Установить(ДатаКурса);
		Запись = НаборЗаписей.Добавить();
		Запись.Валюта = Валюта;
		Запись.Период = ДатаКурса;
		Запись.Курс = Курс;
		Запись.Кратность = Кратность;
		
		Записывать = Истина;
		Если ОбщегоНазначения.ПодсистемаСуществует("СтандартныеПодсистемы.ДатыЗапретаИзменения") Тогда
			МодульДатыЗапретаИзмененияСлужебный = ОбщегоНазначения.ОбщийМодуль("ДатыЗапретаИзмененияСлужебный");
			Если МодульДатыЗапретаИзмененияСлужебный.ЗапретИзмененияПроверяется(Метаданные.РегистрыСведений.КурсыВалют) Тогда
				МодульДатыЗапретаИзменения = ОбщегоНазначения.ОбщийМодуль("ДатыЗапретаИзменения");
				Записывать = Не МодульДатыЗапретаИзменения.ИзменениеЗапрещено(НаборЗаписей);
				Если Не Записывать Тогда
					Если ДатаЗапрета = Неопределено Тогда
						ДатаЗапрета = ДатаКурса;
					Иначе
						ДатаЗапрета = Макс(ДатаЗапрета, ДатаКурса);
					КонецЕсли;
				КонецЕсли;
			КонецЕсли;
		КонецЕсли;
		
		Если Записывать Тогда
			НаборЗаписей.Записать();
		КонецЕсли;
		
		ЧислоЗагруженныхДней = ЧислоЗагруженныхДней + 1;
	КонецЦикла;
	
	Если ЭтоАдресВременногоХранилища(ПутьКФайлу) Тогда
		УдалитьФайлы(ИмяФайла);
		УдалитьИзВременногоХранилища(ПутьКФайлу);
	КонецЕсли;
	
	ПояснениеОЗагрузке = "";
	Если ЧислоЗагружаемыхДнейВсего <> ЧислоЗагруженныхДней Тогда
		Если ЧислоЗагруженныхДней = 0 Тогда
			ПояснениеОЗагрузке = НСтр("ru = 'Курсы валюты %1 (%2) не загружены. Нет данных.'");
		Иначе
			ПояснениеОЗагрузке = НСтр("ru = 'Загружены не все курсы по валюте %1 (%2).'");
		КонецЕсли;
	КонецЕсли;
	
	Если Не ПустаяСтрока(ПояснениеОЗагрузке) Тогда
		ПояснениеОЗагрузке = СтроковыеФункцииКлиентСервер.ПодставитьПараметрыВСтроку(ПояснениеОЗагрузке, Валюта.Наименование, Валюта.Код);
	КонецЕсли;
	
	Если ДатаЗапрета <> Неопределено Тогда
		ПояснениеОЗагрузке = ПояснениеОЗагрузке + Символы.ПС + СтроковыеФункцииКлиентСервер.ПодставитьПараметрыВСтроку(НСтр("ru = 'Загрузка курсов валюты %1(%2) ограничена датой запрета изменений %3.
			|Курсы запрещенного периода были пропущены при загрузке.'"), Валюта.Наименование, Валюта.Код, Формат(ДатаЗапрета, "ДЛФ=D"));
	КонецЕсли;
	
	ПояснениеОЗагрузке = СокрЛП(ПояснениеОЗагрузке);
	
	СообщенияПользователю = ПолучитьСообщенияПользователю(Истина);
	СписокОшибок = Новый Массив;
	Для Каждого СообщениеПользователю Из СообщенияПользователю Цикл
		СписокОшибок.Добавить(СообщениеПользователю.Текст);
	КонецЦикла;
	СписокОшибок = ОбщегоНазначенияКлиентСервер.СвернутьМассив(СписокОшибок);
	ПояснениеОЗагрузке = ПояснениеОЗагрузке + ?(ПустаяСтрока(ПояснениеОЗагрузке), "", Символы.ПС) + СтрСоединить(СписокОшибок, Символы.ПС);
	
	Возврат ПояснениеОЗагрузке;
	
КонецФункции

////////////////////////////////////////////////////////////////////////////////
// Локальные служебные процедуры и функции.

// Выделяет из переданной строки первое значение
//  до символа "TAB".
//
// Параметры: 
//  ИсходнаяСтрока - Строка - строка для разбора.
//
// Возвращаемое значение:
//  подстроку до символа "TAB"
//
Функция ВыделитьПодСтроку(ИсходнаяСтрока)
	
	Перем ПодСтрока;
	
	Поз = СтрНайти(ИсходнаяСтрока,Символы.Таб);
	Если Поз > 0 Тогда
		ПодСтрока = Лев(ИсходнаяСтрока,Поз-1);
		ИсходнаяСтрока = Сред(ИсходнаяСтрока,Поз + 1);
	Иначе
		ПодСтрока = ИсходнаяСтрока;
		ИсходнаяСтрока = "";
	КонецЕсли;
	
	Возврат ПодСтрока;
	
КонецФункции

////////////////////////////////////////////////////////////////////////////////
// Обработчики условных вызовов в другие подсистемы.

// Обновляет связи между справочником валют и файлом поставляемых курсов
// в зависимости от способа установки курса валют.
//
// Параметры:
//   Валюта - СправочникОбъект.Валюты.
//
Функция ПриОбновленииКурсовВалютВМоделиСервиса(Валюта) Экспорт
	
	Если ОбщегоНазначения.ПодсистемаСуществует("СтандартныеПодсистемы.РаботаВМоделиСервиса.ВалютыВМоделиСервиса") Тогда
		МодульКурсыВалютСлужебныйВМоделиСервиса = ОбщегоНазначения.ОбщийМодуль("КурсыВалютСлужебныйВМоделиСервиса");
		МодульКурсыВалютСлужебныйВМоделиСервиса.ЗапланироватьКопированиеКурсовВалюты(Валюта);
	КонецЕсли;
	
КонецФункции

#КонецОбласти
