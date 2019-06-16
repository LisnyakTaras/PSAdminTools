для нормальной работы приложения нужно (сделать единожды на компе):

1) Скопировать программу "PsExec.exe" в каталог- "C:\Windows\System32", взять ее можно тут - \\atbmarket.com\atb-soft\ПО\ТП\PsTools
или скачать с сайта Майкрософта;
2) Обязательно должна стоять консоль SCCM;
3) Запустить с повышеными привилегиями консоль PowerShell x86 и запустить комманды
	- Enable-PSRemoting -Force
	- Set wsman:\localhost\client\trustedhosts * -Force
	- Unblock-File 'C:\Program Files (x86)\Microsoft Configuration Manager\AdminConsole\bin\ConfigurationManager.psd1'
	- Set-ExecutionPolicy RemoteSigned

(При каждом запуске ПО)
1) При каждом запуске, обязательно введи учетные данные локального админа и нажми кнопку "Поехали"!!!

Исходники лежат тут:
https://github.com/LisnyakTaras/PSAdminTools
Видео по работе утилиты тут:
https://drive.google.com/open?id=1KMjr0OWdDIP6Peo_O9BFa-W--u5qgd8v