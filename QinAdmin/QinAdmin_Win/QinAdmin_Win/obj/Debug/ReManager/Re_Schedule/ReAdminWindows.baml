   M S B A M L   `   `   `  ����G  CQinAdmin_Win, Version=1.0.0.0, Culture=neutral, PublicKeyToken=nullW0clr-namespace:QinAdmin_Win.ReManager.Re_Schedule"QinAdmin_Win.ReManager.Re_Schedule  5   	   7    1QinAdmin_Win.ReManager.Re_Schedule.ReAdminWindows   5   	   W SPresentationCore, Version=4.0.0.0, Culture=neutral, PublicKeyToken=31bf3856ad364e35R NWindowsBase, Version=4.0.0.0, Culture=neutral, PublicKeyToken=31bf3856ad364e35\ XPresentationFramework, Version=4.0.0.0, Culture=neutral, PublicKeyToken=31bf3856ad364e35D 9http://schemas.microsoft.com/winfx/2006/xaml/presentation    5   	   R NSystem.Xaml, Version=4.0.0.0, Culture=neutral, PublicKeyToken=b77a5c561934e089:x,http://schemas.microsoft.com/winfx/2006/xaml     5   	   @d2http://schemas.microsoft.com/expression/blend/2008     5   	   Jmc;http://schemas.openxmlformats.org/markup-compatibility/2006     5   	   Blocal0clr-namespace:QinAdmin_Win.ReManager.Re_Schedule     5   	   -   5          � Title$  AdminStudentWindow��5      $	��450��6+   $	��800��68   .��5	      ]� $��8,8,8,0q�6   .+�5
   
   ]� ���	#FF67E642$	��Top=�6+   $��30��6@   .+�5      �� -   5         ��Name$ 	AddButton��5      $��增加��6(   $��30��65   $	��Top=�6A   $��75��6Y   6d   �� 5      -   5        $ 
EditButton��5      $��修改��6)   $��30��66   $	��Top=�6B   $��75��6Z   6e   �� 5      -   5        $ DeleteButton��5      $��删除��6+   $��30��68   $	��Top=�6D   $��75��6\   6g   �� 5      -   5        $ EditPeopleButton��5      $��编辑课程人员��6/   $��30��6@   $	��Top=�6L   $��75��6d   $��Right=�6o   6�   �� 5      -   5        $ FilterButton��5      $��查找��6+   $��30��68   $	��Top=�6D   $��75��6\   $��Right=�6g   6~   �� 5      -   5         ��Name$ KeywordTextBox��5       �� TextWrapping$
 Wrap=�6.   $	��Top=�6B   $��30��6Z   $��Center=�6f   5      �� 5   
   -   5         ��Name$ 	InfoLabel��5      $��建筑管理器��6#   $��Bottom=�63   $��30��6K   $��Center=�6W   ���	#FFF0EEEE$��	-8,8,-8,0q�6�   ]� 5   
   $��Bottom=�6   $��30��6-   ��.  .+�5      �� -	   5        $ ReloadButton��5      $��刷新数据��6+   $��30��6:   $	��Top=�6F   $��75��6^   $
��Left=�6i   6   �� 5      -
   5        $ DownLoadButton��5      $��下载数据��6-   $��30��6<   $	��Top=�6H   $��75��6`   $��Right=�6k   6�   �� 5      -   5        $ UploadButton��5      $��确认导入��6+   $��30��6:   $	��Top=�6F   $��75��6^   $��Right=�6i   6�   �� 5      -   5        $ ImportExcelTemplateButton��5      $��导入数据��68   $��75��6G   $��Right=�6R   $��30��6�   $	��Top=�6�   �� 5      -   5        $ ExportExcelTemplateButton��5      $��下载模板��68   $��30��6G   $	��Top=�6S   $��75��6k   $��Right=�6v   6�   5      �� 5   
   $��Visible=�6   $	��0,8q�6?   .��5      &   System.Windows.Controls.DataGrid  -   5          Name$ RelationDataGrid��5         AutoGenerateColumns .     
IsReadOnly .    SelectionMode$ Single=�6`   	   Columns	 5      0  *System.Windows.Controls.DataGridTextColumn  5      ,  &System.Windows.Controls.DataGridColumn
   Header$
 日程编号��6%   1  +System.Windows.Controls.DataGridBoundColumn   Binding 64   �� *ID+  5      $
 课程编号��6%    64   �� *	Course.ID+  5      $
 课程名称��6)    68   �� *Course.Name+  5       $
 教室编号��6)    68   �� *	Room.ID+  5!      $
 教室名称��6)    68   �� *	Room.Name+  5"      $
 起始节次��6)    68   �� *StartSection.Name+  5#      $
 持续节次��6)    68   �� *ContinueSection+  5$      $
 起始日期��6)    68   �� *	StartDate+  5%      $
 持续次数��6)    68   �� *ContinueWeek+  5&      $
 任课教师数量��6)    6:   �� *Professors.Count+  5'      $
 课程学生数量��6)    6:   �� *Students.Count+5)      5*      5+      5,      