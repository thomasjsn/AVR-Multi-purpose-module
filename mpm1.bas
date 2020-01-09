'--------------------------------------------------------------
'                   Thomas Jensen | stdout.no
'--------------------------------------------------------------
'  file: AVR_MPM1
'  date: 06/12/2006
'--------------------------------------------------------------
$crystal = 8000000
Config Portd = Input
Config Portb = Output
Config Watchdog = 1024

Dim A As Byte , Lifesignal As Integer , Dorled As Integer
Dim Stuelys As Integer , Rspledg As Integer , Rspledr As Integer
Dim Rspactive As Integer , Rspledgr As Integer , Rspalarm As Integer
Dim Rspalert As Integer , Irled As Integer

Lifesignal = 21
Dorled = 0
Stuelys = 0
Rspledg = 0
Rspledr = 0
Rspactive = 0
Rspalarm = 0
Rspalert = 0

Portb = 0
Portb.0 = Not Portb.0

For A = 1 To 15
    Portb.0 = Not Portb.0
    Portb.1 = Not Portb.1
    Portb.4 = Not Portb.4
    Portb.5 = Not Portb.5
    Waitms 200
Next A

Waitms 500

Start Watchdog
Portb = 0

Main:
'IR LED
If Pind.1 = 1 And Irled = 0 Then Irled = 2
'Door LED
If Pind.2 = 1 And Dorled = 0 Then Dorled = 21

'Flash porch LED
If Dorled = 20 Then Portb.4 = 1
If Dorled = 10 Then Portb.4 = 0
If Dorled > 0 Then Dorled = Dorled - 1

'Flash IR sensor LED
If Irled = 2 Then Portb.5 = 1
If Irled = 1 Then Portb.5 = 0
If Irled > 0 Then Irled = Irled - 1

'ALU signal on (NC)
If Pind.1 = 1 Or Pind.2 = 1 Then Portb.2 = 0
'ALU signal off (NC)
If Pind.1 = 0 And Pind.2 = 0 Then Portb.2 = 1

'Lights livingroom off
If Pind.3 = 0 Then Stuelys = 21
If Pind.4 = 0 Then Stuelys = 461
If Stuelys = 10 Then Portb.3 = 1
If Stuelys = 0 Then Portb.3 = 0
If Stuelys > 0 Then Stuelys = Stuelys - 1

'Panel test
If Pind.0 = 0 And Rspledg = 0 And Rspalarm = 0 Then
   'Activate green LED
   Rspledg = 21
   'Arm alarm
   Rspactive = 1
   End If

If Pind.0 = 1 And Rspalarm = 0 Then Rspalert = 1

If Rspalert = 1 And Rspactive = 1 And Rspledr = 0 And Rspledg = 0 Then
   'Activate green and red LED
   Rspledg = 11
   Rspledr = 11
   'Panel faulted
   Rspalarm = 1
   'Activate lighttower/sound
   Portb.6 = 1
   End If

'Reset panel fault
If Pind.5 = 1 Then
   Rspactive = 0
   Rspalarm = 0
   Rspalert = 0
   'Deactivate lighttower/sound
   Portb.6 = 0
   End If

'Activate red LED
If Pind.0 = 1 And Rspalarm = 0 And Rspledr = 0 Then Rspledr = 21

'Green panel LED
If Rspledg = 11 Then Portb.0 = 1
If Rspledg = 6 Then Portb.0 = 0
If Rspledg > 0 Then Rspledg = Rspledg - 1

'Red panel LED
If Rspledr = 6 Then Portb.1 = 1
If Rspledr = 1 Then Portb.1 = 0
If Rspledr > 0 Then Rspledr = Rspledr - 1

'Lifesignal
If Lifesignal > 0 Then Lifesignal = Lifesignal - 1
If Lifesignal = 6 Then Portb.7 = 1
If Lifesignal = 1 Then Portb.7 = 0
If Lifesignal = 0 Then Lifesignal = 21

'Loop cycle
Reset Watchdog
Waitms 100
Goto Main
End