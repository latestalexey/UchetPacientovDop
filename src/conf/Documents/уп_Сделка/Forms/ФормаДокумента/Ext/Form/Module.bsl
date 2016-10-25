﻿&НаКлиенте
Процедура КлиентПриИзменении(Элемент)
	Элементы.СКемЗаключенДоговор.СписокВыбора.Очистить();
	Элементы.СКемЗаключенДоговор.СписокВыбора.ЗагрузитьЗначения(ПолучитьОтветственныхПоКлиенту());
КонецПроцедуры

&НаСервере
Функция ПолучитьОтветственныхПоКлиенту()
	МассивОтветственных = Новый Массив;
	Если НЕ Объект.Клиент.Пустая() Тогда 
		Если ЗначениеЗаполнено(Объект.Клиент.Отец) Тогда
			МассивОтветственных.Добавить(Объект.Клиент.Отец);
		КонецЕсли;
		Если ЗначениеЗаполнено(Объект.Клиент.Мать) Тогда
			МассивОтветственных.Добавить(Объект.Клиент.Мать);
		КонецЕсли;
	КонецЕсли;
	Возврат МассивОтветственных;
КонецФункции

&НаКлиенте
Процедура СКемЗаключенДоговорНачалоВыбора(Элемент, ДанныеВыбора, СтандартнаяОбработка)
	СтандартнаяОбработка = ложь;
	ДанныеВыбора = Новый СписокЗначений;
	ДанныеВыбора.ЗагрузитьЗначения(ПолучитьОтветственныхПоКлиенту());
КонецПроцедуры
