��� ���������� ������ ���������� ����� (������� �������� �� �����):

1) ����������� ��������� "PsExec.exe" � �������- "C:\Windows\System32", ����� �� ����� ��� - \\atbmarket.com\atb-soft\��\��\PsTools
��� ������� � ����� �����������;
2) ����������� ������ ������ ������� SCCM;
3) ��������� � ���������� ������������ ������� PowerShell x86 � ��������� ��������
	- Enable-PSRemoting -Force
	- Set wsman:\localhost\client\trustedhosts * -Force
	- Unblock-File 'C:\Program Files (x86)\Microsoft Configuration Manager\AdminConsole\bin\ConfigurationManager.psd1'
	- Set-ExecutionPolicy RemoteSigned

(��� ������ ������� ��)
1) ��� ������ �������, ����������� ����� ������� ������ ���������� ������ � ����� ������ "�������"!!!

��������� ����� ���:
https://github.com/LisnyakTaras/PSAdminTools
����� �� ������ ������� ���:
https://drive.google.com/open?id=1KMjr0OWdDIP6Peo_O9BFa-W--u5qgd8v