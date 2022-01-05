// Use .apex files to store anonymous Apex.
// You can execute anonymous Apex in VS Code by selecting the
//     apex text and running the command:
//     SFDX: Execute Anonymous Apex with Currently Selected Text
// You can also execute the entire file by running the command:
//     SFDX: Execute Anonymous Apex with Editor Contents
Integer limitPublishImmediate = System.Limits.getPublishImmediateDML();
System.debug('limitPublishImmediate is: '+limitPublishImmediate);
Integer limitDML = System.Limits.getDMLStatements();
System.debug('limitDML is: '+limitDML);
string tempvar = 'Enter_your_name_here';
System.debug('Hello World!');
System.debug('My name is ' + tempvar);