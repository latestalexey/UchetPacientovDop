﻿
Процедура ОбработкаПроведения(Отказ, Режим)
	//{{__КОНСТРУКТОР_ДВИЖЕНИЙ_РЕГИСТРОВ
	// Данный фрагмент построен конструктором.
	// При повторном использовании конструктора, внесенные вручную изменения будут утеряны!!!

	// регистр ОстаткиПроцедур Приход
	Движения.ОстаткиПроцедур.Записывать = Истина;
	Для Каждого ТекСтрокаСписокПроцедур Из СписокПроцедур Цикл
		Движение = Движения.ОстаткиПроцедур.Добавить();
		Движение.ВидДвижения = ВидДвиженияНакопления.Приход;
		Движение.Период = НачалоЗанятий;
		Движение.Клиент = Клиент;
		Движение.Процедура = ТекСтрокаСписокПроцедур.Процедура;
		Движение.Количество = ТекСтрокаСписокПроцедур.Количество;
	КонецЦикла;

	//}}__КОНСТРУКТОР_ДВИЖЕНИЙ_РЕГИСТРОВ
КонецПроцедуры

Процедура ОбработкаЗаполнения(ДанныеЗаполнения, ТекстЗаполнения, СтандартнаяОбработка)
	НачалоЗанятий = ТекущаяДата();
	Организация = Справочники.Организации.ОрганизацияПоУмолчанию();
КонецПроцедуры
