   M S B A M L   `   `   `  ����G  CQinAdmin_Win, Version=1.0.0.0, Culture=neutral, PublicKeyToken=nullI)clr-namespace:QinAdmin_Win.SectionManagerQinAdmin_Win.SectionManager  5   	   5    /QinAdmin_Win.SectionManager.SectionEditorWindow   5   	   W SPresentationCore, Version=4.0.0.0, Culture=neutral, PublicKeyToken=31bf3856ad364e35R NWindowsBase, Version=4.0.0.0, Culture=neutral, PublicKeyToken=31bf3856ad364e35\ XPresentationFramework, Version=4.0.0.0, Culture=neutral, PublicKeyToken=31bf3856ad364e35D 9http://schemas.microsoft.com/winfx/2006/xaml/presentation    5   	   R NSystem.Xaml, Version=4.0.0.0, Culture=neutral, PublicKeyToken=b77a5c561934e089:x,http://schemas.microsoft.com/winfx/2006/xaml     5   	   @d2http://schemas.microsoft.com/expression/blend/2008     5   	   Jmc;http://schemas.openxmlformats.org/markup-compatibility/2006     5   	   ;local)clr-namespace:QinAdmin_Win.SectionManager     5   	   X TXceed.Wpf.Toolkit, Version=3.8.0.0, Culture=neutral, PublicKeyToken=3e4669d2f30244f44xctk)http://schemas.xceed.com/wpf/xaml/toolkit  5   	   -   5          � Title$  SectionEditorWindow��5	   
   $��353.773��6&   $��270.755��67   .��5
      ]� ��.  $��32q�6&   .+�5   
   �� $��学时编号��6   $	��Top=�6   �� 5   
   -   5         ��Name$ SectionIDTextBox��5      $	��Top=�6,   �� 5   
   $��学时名称��6   $	��Top=�6   �� 5   
   -   5        $ SectionNameTextBox��5      $	��Top=�6.   �� 5   
   $��学时顺序��6   $	��Top=�6   �� 5   
   -   5        $ SectionOrderTextBox��5      $	��Top=�6/   �� 5   
   $��开始时间��6   $	��Top=�6   "  Xceed.Wpf.Toolkit.TimePicker  5   
   -   5          Name$ SectionStartTimePicker��5      $	��Top=�6;   �� 5   
   $��结束时间��6   $	��Top=�6     5   
   -   5        $ SectionEndTimePicker��5      $	��Top=�69   �� 5   
   -   5         ��Name$ ConfirmButton��5      $��确定��6(   $��Bottom=�65   6M   5      5      