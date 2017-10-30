-- Это lua скрипт для FEMM 4.0
--------------------------------------------------------------------------------
---- Версия 2.4.04 от 22 января 2006 г. 
--------------------------------------------------------------------------------
-- Читаем из файла начальные параметры
--------------------------------------------------------------------------------
File_name=prompt ("Введите имя файла с данными гауса, без расширения .txt") 

handle = openfile(File_name .. ".txt","r")
pustaja_stroka = read(handle, "*l") -- просто пропускаем строки 4 шт
pustaja_stroka = read(handle, "*l")
pustaja_stroka = read(handle, "*l")
pustaja_stroka = read(handle, "*l")

C = read(handle, "*n", "*l") 	-- Емкость конденсатора, микроФарад		
U = read(handle, "*n", "*l")	-- Напряжение на конденсаторе, Вольт 

Dpr = read(handle, "*n", "*l")	-- Диаметр обмоточного провода катушки, милиметр
Tiz = read(handle, "*n", "*l")	-- Удвоенная толщина изоляции провода (разница диаметра в изоляции и диаметра голого), мм
Lkat = read(handle, "*n", "*l")	-- Длина катушки (не задавать меньше диаметра обмот. провода катушки), милиметр				
Dkat = read(handle, "*n", "*l")	-- Внешний диаметр катушки, милиметр
Lmag = read(handle, "*n", "*l")	-- Толщина внешнего магнитопровода, по форме повторяет катушку, если ноль то его нет, милиметр
Nom_mat_magnitoprovoda = read(handle, "*n", "*l")	-- материал из которого сделан магнитопровод катушки см. таблицу

Nom_mat_puli = read(handle, "*n", "*l")	-- материал из которого сделана пуля см. таблицу
Lpuli  = read(handle, "*n", "*l")	-- Длина пули, милиметр		
Dpuli = read(handle, "*n", "*l")	-- Диаметр пули, милиметр
Lsdv = read(handle, "*n", "*l")		-- Расстояние, на которое в начальный момент вдвинута пуля в катушку или находится до катушки с минусом, милиметр

Dstvola = read(handle, "*n", "*l")	-- Внешний диаметр ствола (не задавать меньше диаметра пули), милиметр
Vel0 = read(handle, "*n", "*l")		-- Начальная скорость пули, м/с (Вместо 0 лучше какое-то небольшое значение, иначе долго на месте стоит)
delta_t = read(handle, "*n", "*l")	-- Приращение времени, мкС 

closefile(handle)
--------------------------------------------------------------------------------

kRC = 140      -- Постоянная константа RC для распространённых электрколитических нденсаторов, Ом*мкФ
Rcc = (kRC/C)  -- Внутреннее сопротивление конденсатора
Rv = 0.35+Rcc     -- Сопротивление подводящих проводов + сопротивление тиристора + внутреннее сопротивление конденсатора, Ом

Vol =4                -- Кратность свободного пространства вокруг модели (рекомендуется значение от 3 до 5)
Coil_meshsize = 0.5    -- Размер сетки катушки, мм
Proj_meshsize = 0.35    -- Размер сетки пули, мм
max_segm      = 5     -- Максимальный размер сегмента пространства, град

t = 0			-- Начальный момент времени, секунды
sigma = 0.0000000175	-- Удельное сопротивление меди, Ом * Метр
ro = 7800		-- Плотность железа, Кг/Метр^3
pi = 3.1415926535  
--------------------------------------------------------------------------------
-- Начинаем
--------------------------------------------------------------------------------
Start_date= date()


create(0)							-- создаем документ для магнитных задач

mi_probdef(0,"millimeters","axi",1E-8,30)			-- создаем задачу

mi_saveas("temp.fem")						-- сохраняем файл под другим именем

mi_addmaterial("Air",1,1)					-- добавляем материал воздух

mi_addmaterial("Cu",1,1,"","","",58,"","","",4,"","",1,Dpr)	-- добавляем материал медный провод диаметром Dpr проводимостью 58

mi_addcircprop("katushka",0,0,1)				-- добавляем катушку 

dofile ("func.lua")	-- компилируем функции для дальнейшего доступа к ним					
vvod_materiala (Nom_mat_magnitoprovoda,"M")	-- вводим материал магнитопровода назовем его как М и номер материала
Material_magnitoprovoda="M" .. Nom_mat_magnitoprovoda

vvod_materiala (Nom_mat_puli,"P")		---- вводим материал пули назовем его как Р и номер материала
Material_puli="P" .. Nom_mat_puli	

--------------------------------------------------------------------------------
-- Располагаем объекты
--------------------------------------------------------------------------------

--Создаем пространство в Vol раз большее чем катушка
mi_addnode(0,(Lkat+Lmag)*-Vol) 				-- ставим точку
mi_addnode(0,(Lkat+Lmag)*Vol)				-- ставим точку
mi_addsegment(0,(Lkat+Lmag)*-Vol,0,(Lkat+Lmag)*Vol)		-- рисуем линию
mi_addarc(0,(Lkat+Lmag)*-Vol,0,(Lkat+Lmag)*Vol,180,max_segm)	-- рисуем дугу

mi_addblocklabel((Lkat+Lmag)*0.7*Vol,0)				-- добавляем блок	
mi_clearselected()						-- отменяем все 
mi_selectlabel((Lkat+Lmag)*0.7*Vol,0)				-- выделяем метку блока
mi_setblockprop("Air", 1, "", "", "",0) 			-- устанавливаем свойства блока с имнем Air и номером блока 0

mi_zoomnatural()	-- устанавливаем зум так что бы было видно на весь экран

-------------------------------------------------------------------------- Создаем пулю
if Dstvola < Dpuli then Dstvola = Dpuli+0.1 end -- защита от неумех 

-- если длина пули равна диаметру значит шар
if Lpuli==Dpuli then 

	mi_addnode(0,Lkat/2-Lsdv)
	mi_addnode(0,Lkat/2+Lpuli-Lsdv)

	mi_clearselected()
	mi_selectnode (0,Lkat/2-Lsdv)
	mi_selectnode (0,Lkat/2+Lpuli-Lsdv)
	mi_setnodeprop("",1)

	mi_addarc(0,Lkat/2-Lsdv,0,Lkat/2+Lpuli-Lsdv,180,5)


else	-- иначе просто цилиндр

	mi_addnode(0,Lkat/2-Lsdv)
	mi_addnode(Dpuli/2,Lkat/2-Lsdv)
	mi_addnode(Dpuli/2,Lkat/2+Lpuli-Lsdv)
	mi_addnode(0,Lkat/2+Lpuli-Lsdv)

	mi_clearselected()
	mi_selectnode(0,Lkat/2-Lsdv)
	mi_selectnode(Dpuli/2,Lkat/2-Lsdv)
	mi_selectnode(Dpuli/2,Lkat/2+Lpuli-Lsdv)
	mi_selectnode(0,Lkat/2+Lpuli-Lsdv)
	mi_setnodeprop("",1)

	mi_addsegment(Dpuli/2,Lkat/2-Lsdv,Dpuli/2,Lkat/2+Lpuli-Lsdv)
	mi_addsegment(Dpuli/2,Lkat/2+Lpuli-Lsdv,0,Lkat/2+Lpuli-Lsdv)
	mi_addsegment(0,Lkat/2+Lpuli-Lsdv,0,Lkat/2-Lsdv)
	mi_addsegment(0,Lkat/2-Lsdv,Dpuli/2,Lkat/2-Lsdv)

end
mi_addblocklabel(Dpuli/4,Lkat/2+Lpuli/2-Lsdv)
mi_clearselected()
mi_selectlabel(Dpuli/4,Lkat/2+Lpuli/2-Lsdv)
mi_setblockprop(Material_puli, 0, Proj_meshsize, "", "",1)			-- номер блока 1


------------------------------------------------------------------------- Создаем катушку

mi_addnode(Dstvola/2,Lkat/2)			-- основание
mi_addnode(Dstvola/2,-Lkat/2)			-- основание
mi_addnode(Dkat/2,Lkat/2)				-- внешняя начальная часть
mi_addnode(Dkat/2,-Lkat/2)				-- внешняя конечная часть


mi_clearselected()
mi_selectnode(Dstvola/2,Lkat/2)			-- основание
mi_selectnode(Dstvola/2,-Lkat/2)		-- основание
mi_selectnode(Dkat/2,Lkat/2)				
mi_selectnode(Dkat/2,-Lkat/2)				
mi_setnodeprop("",2)

mi_addsegment(Dstvola/2,-Lkat/2,Dstvola/2,Lkat/2)
mi_addsegment(Dstvola/2,Lkat/2,Dkat/2,Lkat/2)
mi_addsegment(Dkat/2,Lkat/2,Dkat/2,-Lkat/2)
mi_addsegment(Dkat/2,-Lkat/2,Dstvola/2,-Lkat/2)


mi_addblocklabel(Dstvola/2+(Dkat/2-Dstvola/2)/2,0)
mi_clearselected()
mi_selectlabel(Dstvola/2+(Dkat/2-Dstvola/2)/2,0)
mi_setblockprop("Cu", 0, Coil_meshsize, "katushka", "",2) -- номер блока 2


-------------------------------------------------------------------------- Создаем внешний магнитопровод
if (Lmag > 0) and (Nom_mat_magnitoprovoda > 0) then 

	
	mi_addnode(Dstvola/2,Lkat/2+Lmag)
	mi_addnode(Dkat/2+Lmag,Lkat/2+Lmag)
	mi_addnode(Dkat/2+Lmag,-Lkat/2-Lmag)	
	mi_addnode(Dstvola/2,-Lkat/2-Lmag)

	mi_clearselected()
	mi_selectnode(Dstvola/2,Lkat/2+Lmag)			-- основание
	mi_selectnode(Dkat/2+Lmag,Lkat/2+Lmag)		-- основание
	mi_selectnode(Dkat/2+Lmag,-Lkat/2-Lmag)				
	mi_selectnode(Dstvola/2,-Lkat/2-Lmag)				
	mi_setnodeprop("",3)	


	mi_addsegment(Dstvola/2,Lkat/2,Dstvola/2,Lkat/2+Lmag)
	mi_addsegment(Dstvola/2,Lkat/2+Lmag,Dkat/2+Lmag,Lkat/2+Lmag)
	mi_addsegment(Dkat/2+Lmag,Lkat/2+Lmag,Dkat/2+Lmag,-Lkat/2-Lmag)

	mi_addsegment(Dkat/2+Lmag,-Lkat/2-Lmag,Dstvola/2,-Lkat/2-Lmag)
	mi_addsegment(Dstvola/2,-Lkat/2-Lmag,Dstvola/2,-Lkat/2)

	mi_addblocklabel(Dkat/2+Lmag/2,0)
	mi_clearselected()
	mi_selectlabel(Dkat/2+Lmag/2,0)
	mi_setblockprop(Material_magnitoprovoda, 1, "", "", "",3)		-- номер блока 3

end

mi_clearselected()


--------------------------------------------------------------------------------
-- система СИ - метр, Фарад
--------------------------------------------------------------------------------
C = C/1000000
Dpriz = Dpr+Tiz -- Диаметр провода в изоляции
Dpr = Dpr/1000
Dpriz = Dpriz/1000		
Lpuli  = Lpuli/1000
Dpuli = Dpuli/1000
Dstvola = Dstvola/1000				
Lkat = Lkat/1000
Dkat = Dkat/1000
Lsdv = Lsdv/1000
Lmag = Lmag/1000
--------------------------------------------------------------------------------

-- Анализируем и запускаем постпроцессор
	
mi_analyze(1)				-- анализируем (скрывая окно анализа "1") 0 - будет видно окно и будет работать медленее
mi_loadsolution()			-- запускаем саму программу пост процессора

mo_groupselectblock(2)
Skat = mo_blockintegral(5) 		-- Площадь сечения катушки, Метр^2 
Vkat = mo_blockintegral(10)		-- Объем катушки, Метр^3
mo_clearblock()
mo_groupselectblock(1)
Vpuli = mo_blockintegral(10)		-- Объем пули, Метр^3	
mo_clearblock()				


Mpuli=ro*Vpuli				-- Масса пули, кг
N=Skat*0.94/(Dpriz*Dpriz)		-- Количество витков в катушке уточнённое
DLprovoda=N * 2 * pi * (Dkat + Dstvola)/4   -- Длина обмоточного провода уточнённая, м

Rkat=sigma*DLprovoda/(pi*(Dpr/2)^2)	-- Сопротивление всего обмоточного провода катушки, Ом
R=Rv+Rkat				-- Полное сопротивление системы

--Устанавливаем число витков, а силу тока 100 А для оценки индуктивности

mi_clearselected()
mi_selectlabel(Dstvola*1000/2+(Dkat/2-Dstvola/2)*1000/2,0) 
mi_setblockprop("Cu", 0, Coil_meshsize, "katushka", "",2,N) -- последнее значение - число витков
mi_clearselected()
mi_modifycircprop("katushka",1,100)


-- Анализируем и запускаем постпроцессор

mi_analyze(1)				-- анализируем (скрывая окно анализа "1") 	
mo_reload()				-- перезапускаем программу пост процессора			
current_re,current_im,volts_re,volts_im,flux_re,flux_im=mo_getcircuitproperties("katushka") -- получаем данные с катушки


L=flux_re/current_re			-- Оценочная индуктивность, Генри

--------------------------------------------------------------------------------
-- НАчало симуляции
--------------------------------------------------------------------------------

dt = delta_t/1000000 -- перевод приращения времени в секунды 
x=0		-- начальная позиция пули
I0=0.00000001   -- достаточно малое значение тока
t=0		-- общее время
Vel=Vel0
Vmax=Vel
Uc = U
I=I0		-- начальное значение тока
Force = 0
Fii = 0
Fix = 0
KC=1		-- счетчик циклов, для вывода в файл
T_I={}		-- создаем массив (таблицу как её называют в Lua)
T_F={}		
T_Vel={}	
T_x={}		
T_t={}
showconsole()							-- показываем окно вывода промежуточных данных
clearconsole()

repeat  	------------------------------------------------------------ начинаем цикл
	
	t = t+dt
	--- Рассчитываем dFi/dI при I и силу
            mi_modifycircprop("katushka",1,I)	-- Устанавливает ток 
            mi_analyze(1)			-- анализируем (скрывая окно анализа "1") 0 - будет видно окно и будет работать медленее	
            mo_reload()				-- перезапускаем программу пост процессора
            mo_groupselectblock(1)

	Force = mo_blockintegral(19)		-- Сила действующая на пулю, Ньютон	
	Force=Force*-1				-- ставим "-" из за координат (направление силы в сторону уменьшения координаты)
			
	current_re,current_im,volts_re,volts_im,flux_re,flux_im=mo_getcircuitproperties("katushka") -- получаем данные с катушки
	Fi0=flux_re			            -- магнитный поток
        mi_modifycircprop("katushka",1,I*1.001)	-- Устанавливает ток, увельченный на 1.001
        mi_analyze(1)				-- анализируем (скрывая окно анализа "1") 0 - будет видно окно и будет работать медленее	
        mo_reload()				-- перезапускаем программу пост процессора			
	current_re,current_im,volts_re,volts_im,flux_re,flux_im=mo_getcircuitproperties("katushka") -- получаем данные с катушки

	Fi1=flux_re			            -- магнитный поток при I=I+0.001*I, dI=0.001*I 
	Fii=(Fi1-Fi0)/(0.001*I)                              -- Рассчитываем dFi/dI

	apuli = Force / Mpuli			-- Ускорение пули, Метр/секунда^2 
	dx = Vel*dt+apuli*dt*dt/2		-- Приращение координаты, метр
	x = x+dx				-- Новая позиция пули
	Vel = Vel+apuli*dt			-- Скорость после приращения, метр/секунда
	
	if Vmax<Vel then Vmax=Vel end



	--- Рассчитываем dFi/dx при x
           
	Fix= Force/I
	------- Расчитываем ток и напряжение на конденсаторе

	I=I+dt*(Uc-I*R-Fix*Vel)/Fii				

	Uc = Uc-dt*I/C


	if Uc< U*0.2 then  break end 

	Epuli = (Mpuli*Vel^2)/2 - (Mpuli*Vel0^2)/2
	EC= (C*U^2)/2
	KPD = Epuli*100/EC

  
	print (KPD .. " - % КПД; " .. Vel .. " м/с; " .. I .. " ампер; " .. Uc .. " вольт; " .. Force .. " Ньютон")


	T_I[KC]=I		-- записываем данные в массив

	T_F[KC]=Force		

	T_Vel[KC]=Vel		

	T_x[KC]=x*1000		

	T_t[KC]=t*1000000	

	KC=KC+1

until I<0 -- повторяем расчет, пока не будет напруги

Epuli = (Mpuli*Vel^2)/2 - (Mpuli*Vel0^2)/2
EC= (C*U^2)/2
KPD = Epuli*100/EC

showconsole()							-- показываем окно вывода промежуточных данных
clearconsole()
print ("-----------------------------------")						
print ("Начало симуляции " .. Start_date)
print ("Емкость конденсатора, микроФарад= " .. C*1000000)
print ("Напряжение на конденсаторе, Вольт = " .. U)
print ("Сопротивление общее, Ом = "..R)
print ("Внешнее сопротивление, Ом = " .. Rv)
print ("Сопротивление катушки, Oм = "..Rkat)
print ("Количество витков в катушке = "..N)
print ("Диаметр обмоточного провода катушки, милиметр = " .. Dpr*1000)
print ("Длина провода в катушке, метр = "..DLprovoda)
print ("Длина катушки, милиметр = " .. Lkat*1000)
print ("Внешний диаметр катушки, милиметр = " .. Dkat*1000)
print ("Индуктивность катушки с пулей в начальном положении, микроГенри= "..L*1000000)
print ("Толщина внешнего магнитопровода, милиметр = " .. Lmag*1000)
print ("Материал внешнего магнитопровода катушки = № " .. Nom_mat_magnitoprovoda .. " " .. vyvod_name_materiala(Nom_mat_magnitoprovoda))
print ("Внешний диаметр ствола, милиметр = " .. Dstvola*1000)	
print ("Масса пули, грамм = "..Mpuli*1000)
print ("Длина пули, милиметр = " .. Lpuli*1000)		
print ("Диаметр пули, милиметр = " .. Dpuli*1000)
print ("Расстояние, на которое в начальный момент вдвинута пуля в катушку, милиметр = " .. Lsdv*1000)	
print ("Материал из которго сделана пуля = № " .. Nom_mat_puli .. " " .. vyvod_name_materiala(Nom_mat_puli))
print ("Время процесса (микросек)= " .. t*1000000)
print ("Приращение времени,  микросек=" .. delta_t)
print ("Энергия пули Дж = " .. Epuli)
print ("Энергия конденсатора Дж = " .. EC)
print ("КПД гауса(%)= " .. KPD )
print ("Начальная скорость пули, м/с = " .. Vel0)
print ("Скорость пули на выходе из катушки, м/с= " .. Vel )
print ("Максимальная скорость, которая была достигнута, м/с = " .. Vmax )
print ("Все данные и промежуточные занесены в файл: " .. File_name .. " V = " .. Vel .. ".txt")
print ("Окончания симуляции " .. date())


----------------------------------------------------------------------------------------------------
-- Записываем всё в файл
----------------------------------------------------------------------------------------------------
handle = openfile(File_name .. " V = " .. Vel .. ".txt", "a")-- создаем файл а - будем дописывать в конец файла w - записать стерев всё что было перед тем

write (handle,"--------------------------------------------------------------------------------\n")
write (handle,"Начало симуляции " .. Start_date,"\n")
write (handle,"Емкость конденсатора, микроФарад= " .. C*1000000,"\n")
write (handle,"Напряжение на конденсаторе, Вольт = " .. U,"\n")
write (handle,"Сопротивление общее, Ом = "..R,"\n")
write (handle,"Внешнее сопротивление, Ом = " .. Rv,"\n")
write (handle,"Сопротивление катушки, Oм = "..Rkat,"\n")
write (handle,"Количество витков в катушке = "..N,"\n")
write (handle,"Диаметр обмоточного провода катушки, милиметр = " .. Dpr*1000,"\n")
write (handle,"Длина провода в катушке, метр = "..DLprovoda,"\n")
write (handle,"Длина катушки, милиметр = " .. Lkat*1000,"\n")
write (handle,"Внешний диаметр катушки, милиметр = " .. Dkat*1000,"\n")
write (handle,"Индуктивность катушки с пулей в начальном положении, микроГенри= "..L*1000000,"\n")
write (handle,"Толщина внешнего магнитопровода, милиметр = " .. Lmag*1000,"\n")
write (handle,"Материал внешнего магнитопровода катушки = № " .. Nom_mat_magnitoprovoda .. " " .. vyvod_name_materiala(Nom_mat_magnitoprovoda),"\n")
write (handle,"Внешний диаметр ствола, милиметр = " .. Dstvola*1000,"\n")
write (handle,"Масса пули, грамм = "..Mpuli*1000,"\n")
write (handle,"Длина пули, милиметр = " .. Lpuli*1000,"\n")		
write (handle,"Диаметр пули, милиметр = " .. Dpuli*1000,"\n")
write (handle,"Расстояние, на которое в начальный момент вдвинута пуля в катушку, милиметр = " .. Lsdv*1000,"\n")
write (handle,"Материал из которго сделана пуля = № " .. Nom_mat_puli .. " " .. vyvod_name_materiala(Nom_mat_puli),"\n")
write (handle,"Время процесса (микросек)= " .. t*1000000,"\n")
write (handle,"Приращение времени,  микросек=" .. delta_t,"\n")
write (handle,"Энергия пули Дж = " .. Epuli,"\n")
write (handle,"Энергия конденсатора Дж = " .. EC,"\n")
write (handle,"КПД гауса(%)= " .. KPD,"\n")
write (handle,"Начальная скорость пули, м/с = " .. Vel0,"\n")
write (handle,"Скорость пули на выходе из катушки, м/с= " .. Vel,"\n")
write (handle,"Максимальная скорость, которая была достигнута, м/с = " .. Vmax,"\n")
write (handle,"Окончания симуляции " .. date(),"\n")
write (handle,"-------------------------------Промежуточные данные---------------------------------\n")
write (handle,"Сила тока (А)		Сила д. на пулю (Н)	Скорость (м/с)		Координата х(мм) 	Время (мкС) \n")

for Scet=1,KC-1 do
	write (handle,T_I[Scet],"\t",T_F[Scet],"\t",T_Vel[Scet],"\t",T_x[Scet],"\t",T_t[Scet],"\t","\n")
end
write (handle,"-- Промежуточные данные для графиков --\n")
write (handle,"Сила тока (А)\n")
for Scet=1,KC-1 do
	data1,data2=gsub(T_I[Scet], "%.", ",")
	write (handle,data1,"\n")
end
write (handle,"Сила д. на пулю (Н)\n")
for Scet=1,KC-1 do
	data1,data2=gsub(T_F[Scet], "%.", ",")
	write (handle,data1,"\n")
end
write (handle,"Скорость (м/с)\n")
for Scet=1,KC-1 do
	data1,data2=gsub(T_Vel[Scet], "%.", ",")
	write (handle,data1,"\n")
end
write (handle,"Координата х(мм)\n")
for Scet=1,KC-1 do
	data1,data2=gsub(T_x[Scet], "%.", ",")
	write (handle,data1,"\n")
end
write (handle,"Время (мкс)\n")
for Scet=1,KC-1 do
	data1,data2=gsub(T_t[Scet], "%.", ",")
	write (handle,data1,"\n")
end
closefile(handle)

-- Удаляем промежуточные файлы
remove ("temp.fem")
remove ("temp.ans")

