This is an alternative implementation of the "Matrix_CRF_From_TAUG_Dyslipidemia_1_0" example

"odm132.xml" is how it would be implemented in ODM 1.3.2, using a repeating ItemGroup but without any of the new features in ODM 2.0

"odm20.xml" is how the same basic structure would be implemented in ODM 2.0. The two main differences are it provides information about how the ItemGroup should repeat, and the FormDef/FormData becomes an ItemGroupDef/ItemGroupData

"rave.png" shows how this structure would look in Rave.

This allows collection of the same data shown in "Matrix_CRF_From_TAUG_Dyslipidemia_1_0", but without the need to add ValueLists. In my opinion it is vastly simpler. 

