Blob exampleIv = Blob.valueOf('Example of IV123');
Blob key = Crypto.generateAesKey(128);
Blob data = Blob.valueOf('Data to be encrypted');
Blob encrypted = Crypto.encrypt('AES128', key, exampleIv, data);

Blob decrypted = Crypto.decrypt('AES128', key, exampleIv, encrypted);
String decryptedString = decrypted.toString();
System.debug('decrypted string is: '+decryptedString);
System.assertEquals('Data to be encrypted', decryptedString);