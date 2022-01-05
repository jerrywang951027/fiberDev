let definition =
      {"dataSource":{"contextVariables":[],"orderBy":{},"type":null,"value":{}},"dynamicCanvasWidth":{"type":"desktop"},"enableLwc":true,"events":[{"actionData":{"card":"{card}","stateAction":{"eventName":"updatedatasource","id":"flex-action-1625835860175","message":"{\"type\":\"IntegrationProcedures\",\"value\":{\"ipMethod\":\"CON_ServiceVisits\",\"vlocityAsync\":false,\"inputMap\":{\"premisesId\":\"{action.premisesId}\",\"pageSize\":\"2\",\"status\":\"Open\"}},\"orderBy\":{\"name\":\"\",\"isReverse\":false},\"contextVariables\":[{\"name\":\"action.premisesId\",\"val\":\"a4I0n000001FVv7EAG\",\"id\":2}]}","type":"cardAction"}},"channelname":"serviceAccountChannel","displayLabel":"serviceAccountChannel:service_account_channel","element":"action","eventLabel":"pubsub","eventname":"service_account_channel","eventtype":"pubsub","key":"event-0","recordIndex":"0"}],"isFlex":true,"isRepeatable":true,"lwc":{"DeveloperName":"cfCON_UpcomingVisits_1_GoogleFiber","Id":"0Rb8G0000000A6ESAU","MasterLabel":"cfCON_UpcomingVisits_1_GoogleFiber","NamespacePrefix":"c","ManageableState":"unmanaged"},"states":[{"actions":[],"childCards":["CON_ServiceVisitAppointment"],"components":{"layer-0":{"children":[{"children":[{"children":[{"children":[{"children":[{"class":"slds-col ","element":"flexIcon","elementLabel":"Block-0-Block-0-Icon-0","key":"element_element_element_element_block_0_0_block_0_0_block_1_0_flexIcon_0_0","name":"Icon","parentElementKey":"element_element_element_block_0_0_block_0_0_block_1_0","property":{"extraclass":"slds-icon_container slds-icon-standard-service-crew","iconName":"standard:service_crew","iconType":"Salesforce SVG","imgsrc":"","record":"{record}","size":"medium","variant":"inverse"},"size":{"default":"2","isResponsive":false,"large":"1","medium":"1","small":"1"},"stateIndex":0,"styleObject":{"background":{"color":"","image":"","position":"","repeat":"","size":""},"border":{"color":"","radius":"","style":"","type":"","width":""},"class":"","container":{"class":""},"elementStyleProperties":{},"inlineStyle":"--sds-c-icon-color-background: #1589ee","margin":[],"padding":[],"size":{"default":"2","isResponsive":false,"large":"1","medium":"1","small":"1"},"sizeClass":"slds-size_2-of-12 ","style":"     : #ccc 1px solid; \n         --sds-c-icon-color-background: #1589ee","text":{"align":"","color":""}},"type":"element"},{"class":"slds-col ","element":"outputField","elementLabel":"Block-0-Block-0-Text-1","key":"element_element_element_element_block_0_0_block_0_0_block_1_0_outputField_1_0","name":"Text","property":{"card":"{card}","mergeField":"%3Cdiv%3E%3Cspan%20style=%22font-size:%2012pt;%22%3EUpcoming%20Visits%3C/span%3E%3C/div%3E","record":"{record}"},"size":{"default":"10","isResponsive":false},"stateIndex":0,"styleObject":{"background":{"color":"","image":"","position":"","repeat":"","size":""},"border":{"color":"","radius":"","style":"","type":"","width":""},"class":"slds-p-vertical_xx-small ","container":{"class":""},"elementStyleProperties":{},"inlineStyle":"","margin":[],"padding":[{"label":"vertical:xx-small","size":"xx-small","type":"vertical"}],"size":{"default":"10","isResponsive":false},"sizeClass":"slds-size_10-of-12 ","style":"             ","text":{"align":"","color":""}},"type":"text"}],"class":"slds-col ","element":"block","elementLabel":"Block-0-Block-0-Block-1","key":"element_element_element_element_block_0_0_block_0_0_block_0_0_block_0_0","name":"Block","parentElementKey":"element_element_element_block_0_0_block_0_0_block_0_0","property":{"card":"{card}","collapsedByDefault":false,"collapsible":false,"label":"Block","record":"{record}"},"size":{"default":"9","isResponsive":false},"stateIndex":0,"styleObject":{"background":{"color":"","image":"","position":"","repeat":"","size":""},"border":{"color":"","radius":"","style":"","type":"","width":""},"class":"","container":{"class":""},"elementStyleProperties":{},"inlineStyle":"","margin":[],"padding":[],"size":{"default":"9","isResponsive":false},"sizeClass":"slds-size_9-of-12 ","style":"     : #ccc 1px solid; \n         ","text":{"align":"","color":""}},"type":"block"}],"class":"slds-col ","element":"block","elementLabel":"Block-0-Block-0-Block-0","key":"element_element_element_block_0_0_block_0_0_block_0_0","name":"Block","parentElementKey":"element_element_block_0_0_block_0_0","property":{"card":"{card}","collapsedByDefault":false,"collapsible":false,"label":"Block","record":"{record}"},"size":{"default":"12","isResponsive":false},"stateIndex":0,"styleObject":{"background":{"color":"#fafaf9","image":"","position":"","repeat":"","size":""},"border":{"color":"","radius":"","style":"","type":"","width":""},"class":"slds-p-around_medium ","container":{"class":""},"elementStyleProperties":{},"inlineStyle":"","margin":[],"padding":[{"label":"around:medium","size":"medium","type":"around"}],"size":{"default":"12","isResponsive":false},"sizeClass":"slds-size_12-of-12 ","style":"background-color:#fafaf9;     : #ccc 1px solid; \n         ","text":{"align":"","color":""}},"type":"block"},{"children":[{"class":"slds-col ","element":"childCardPreview","elementLabel":"Block-0-Block-0-Block-2-FlexCard-0","key":"element_element_element_element_block_0_0_block_0_0_block_1_0_childCardPreview_0_0","name":"FlexCard","parentElementKey":"element_element_element_block_0_0_block_0_0_block_1_0","property":{"cardName":"CON_ServiceVisitAppointment","cardNode":"{record.tickets}","data-conditions":{"group":[],"id":"state-condition-object","isParent":true},"isChildCardTrackingEnabled":false,"recordId":"{recordId}","selectedState":"Active"},"size":{"default":"12","isResponsive":false},"stateIndex":0,"styleObject":{"background":{"color":"","image":"","position":"","repeat":"","size":""},"border":{"color":"","radius":"","style":"","type":"","width":""},"class":"","container":{"class":""},"customClass":"","elementStyleProperties":{},"inlineStyle":"","margin":[],"padding":[],"size":{"default":"12","isResponsive":false},"sizeClass":"slds-size_12-of-12 ","style":"             ","text":{"align":"","color":""}},"type":"element"}],"class":"slds-col ","element":"block","elementLabel":"Block-0-Block-0-Block-2","key":"element_element_element_block_0_0_block_0_0_block_1_0","name":"Block","parentElementKey":"element_element_block_0_0_block_0_0","property":{"card":"{card}","collapsedByDefault":false,"collapsible":false,"data-conditions":{"group":[],"id":"state-condition-object","isParent":true},"label":"Block","record":"{record}"},"size":{"default":"12","isResponsive":false},"stateIndex":0,"styleObject":{"background":{"color":"","image":"","position":"","repeat":"","size":""},"border":{"color":"","radius":"","style":"","type":"","width":""},"class":"slds-p-around_small ","container":{"class":""},"elementStyleProperties":{},"inlineStyle":"","margin":[],"padding":[{"label":"around:small","size":"small","type":"around"}],"size":{"default":"12","isResponsive":false},"sizeClass":"slds-size_12-of-12 ","style":"             ","text":{"align":"","color":""}},"type":"block"}],"class":"slds-col ","element":"block","elementLabel":"Block-0-Block-0","key":"element_element_block_0_0_block_0_0","name":"Block","parentElementKey":"element_block_0_0","property":{"card":"{card}","collapsedByDefault":false,"collapsible":false,"label":"Block","record":"{record}"},"size":{"default":"12","isResponsive":false},"stateIndex":0,"styleObject":{"background":{"color":"","image":"","position":"","repeat":"","size":""},"border":{"color":"#f3f2f2","radius":"5px","style":"solid","type":"","width":"1"},"class":"","container":{"class":""},"elementStyleProperties":{},"inlineStyle":"","margin":[],"padding":[],"size":{"default":"12","isResponsive":false},"sizeClass":"slds-size_12-of-12 ","style":"     border-color:#f3f2f2; border-width:1px; border-radius:5px; border-style:solid;     ","text":{"align":"","color":""}},"type":"block"}],"class":"slds-col ","element":"block","elementLabel":"Block-0","name":"Block","property":{"card":"{card}","collapsedByDefault":false,"collapsible":false,"label":"Block","record":"{record}"},"size":{"default":"12","isResponsive":false},"stateIndex":0,"styleObject":{"background":{"color":"","image":"","position":"","repeat":"","size":""},"border":{"color":"#cccccc","radius":"","style":"","type":"","width":""},"class":"","container":{"class":""},"elementStyleProperties":{},"inlineStyle":"","margin":[],"padding":[],"size":{"default":"12","isResponsive":false},"sizeClass":"slds-size_12-of-12 ","style":"     border-color:#cccccc;        ","text":{"align":"","color":""}},"type":"block"}]}},"conditions":{"group":[{"field":"tickets","id":"state-condition-24","operator":"!=","type":"custom","value":"undefined"},{"field":"tickets","id":"state-new-condition-42","logicalOperator":"&&","operator":"!=","type":"custom","value":"null"}],"id":"state-condition-object","isParent":true},"definedActions":{"actions":[]},"documents":[],"fields":[],"isSmartAction":false,"name":"Active","omniscripts":[],"smartAction":{},"styleObject":{"background":{"color":"","image":"","position":"","repeat":"","size":""},"border":{"color":"","radius":"","style":"","type":"","width":""},"class":"slds-card slds-grid slds-p-around_x-small slds-m-around_none ","container":{"class":"slds-card slds-grid"},"elementStyleProperties":{},"inlineStyle":"","margin":[{"label":"around:none","size":"none","type":"around"}],"padding":[{"label":"around:x-small","size":"x-small","type":"around"}],"size":{"default":"12","isResponsive":false},"sizeClass":"slds-size_12-of-12 ","style":"             ","text":{"align":"","color":""}}},{"actions":[],"blankCardState":true,"childCards":[],"components":{"layer-0":{"children":[{"children":[{"children":[{"children":[{"children":[{"class":"slds-col ","element":"flexIcon","elementLabel":"Block-0-Block-0-Icon-0","key":"element_element_element_element_block_0_1_block_0_1_block_1_1_flexIcon_0_1","name":"Icon","parentElementKey":"element_element_element_block_0_1_block_0_1_block_1_1","property":{"extraclass":"slds-icon_container slds-icon-standard-service-crew ","iconName":"standard:service_crew","iconType":"Salesforce SVG","imgsrc":"","record":"{record}","size":"medium","variant":"inverse"},"size":{"default":"2","isResponsive":false},"stateIndex":1,"styleObject":{"background":{"color":"","image":"","position":"","repeat":"","size":""},"border":{"color":"","radius":"","style":"","type":"","width":""},"class":"","container":{"class":""},"elementStyleProperties":{},"inlineStyle":"--sds-c-icon-color-background: #1589ee\n","margin":[],"padding":[],"size":{"default":"2","isResponsive":false},"sizeClass":"slds-size_2-of-12 ","style":"             --sds-c-icon-color-background: #1589ee\n","text":{"align":"","color":""}},"type":"element"},{"class":"slds-col ","element":"outputField","elementLabel":"Block-0-Block-0-Text-1","key":"element_element_element_element_block_0_1_block_0_1_block_1_1_outputField_1_1","name":"Text","property":{"card":"{card}","mergeField":"%3Cdiv%3E%3Cspan%20style=%22font-size:%2012pt;%22%3EUpcoming%20Visits%3C/span%3E%3C/div%3E","record":"{record}"},"size":{"default":"10","isResponsive":false},"stateIndex":1,"styleObject":{"background":{"color":"","image":"","position":"","repeat":"","size":""},"border":{"color":"","radius":"","style":"","type":"","width":""},"class":"slds-p-vertical_xx-small ","container":{"class":""},"elementStyleProperties":{},"inlineStyle":"","margin":[],"padding":[{"label":"vertical:xx-small","size":"xx-small","type":"vertical"}],"size":{"default":"10","isResponsive":false},"sizeClass":"slds-size_10-of-12 ","style":"             ","text":{"align":"","color":""}},"type":"text"}],"class":"slds-col ","element":"block","elementLabel":"Block-0-Block-0-Block-1","key":"element_element_element_element_block_0_1_block_0_1_block_0_1_block_0_1","name":"Block","parentElementKey":"element_element_element_block_0_1_block_0_1_block_0_1","property":{"card":"{card}","collapsedByDefault":false,"collapsible":false,"label":"Block","record":"{record}"},"size":{"default":"9","isResponsive":false},"stateIndex":1,"styleObject":{"background":{"color":"","image":"","position":"","repeat":"","size":""},"border":{"color":"","radius":"","style":"","type":"","width":""},"class":"","container":{"class":""},"elementStyleProperties":{},"inlineStyle":"","margin":[],"padding":[],"size":{"default":"9","isResponsive":false},"sizeClass":"slds-size_9-of-12 ","style":"     : #ccc 1px solid; \n         ","text":{"align":"","color":""}},"type":"block"}],"class":"slds-col ","element":"block","elementLabel":"Block-0-Block-0-Block-0","key":"element_element_element_block_0_1_block_0_1_block_0_1","name":"Block","parentElementKey":"element_element_block_0_1_block_0_1","property":{"card":"{card}","collapsedByDefault":false,"collapsible":false,"label":"Block","record":"{record}"},"size":{"default":"12","isResponsive":false},"stateIndex":1,"styleObject":{"background":{"color":"#fafaf9","image":"","position":"","repeat":"","size":""},"border":{"color":"","radius":"","style":"","type":"","width":""},"class":"slds-p-around_medium ","container":{"class":""},"elementStyleProperties":{},"inlineStyle":"","margin":[],"padding":[{"label":"around:medium","size":"medium","type":"around"}],"size":{"default":"12","isResponsive":false},"sizeClass":"slds-size_12-of-12 ","style":"background-color:#fafaf9;             ","text":{"align":"","color":""}},"type":"block"},{"children":[{"children":[{"class":"slds-col ","element":"outputField","elementLabel":"Text-0","key":"element_element_element_element_element_block_0_1_block_0_1_block_1_1_block_0_1_outputField_0_1","name":"Text","parentElementKey":"element_element_element_element_block_0_1_block_0_1_block_1_1_block_0_1","property":{"card":"{card}","mergeField":"%3Cdiv%3E%3Cspan%20style=%22font-family:%20'Salesforce%20Sans',%20Arial,%20sans-serif;%20font-size:%2010pt;%22%3EThere%20are%20no%20upcoming%20service%20visits.%3C/span%3E%3C/div%3E","record":"{record}"},"size":{"default":"12","isResponsive":false},"stateIndex":1,"styleObject":{"sizeClass":"slds-size_12-of-12"},"type":"text"}],"class":"slds-col ","element":"block","elementLabel":"Block-0-Block-0-Block-2-Block-1","key":"element_element_element_element_block_0_1_block_0_1_block_1_1_block_0_1","name":"Block","parentElementKey":"element_element_element_block_0_1_block_0_1_block_1_1","property":{"card":"{card}","collapsedByDefault":false,"collapsible":false,"data-conditions":{"group":[],"id":"state-condition-object","isParent":true},"label":"Block","record":"{record}"},"size":{"default":"12","isResponsive":false},"stateIndex":1,"styleObject":{"class":"slds-p-around_x-small","padding":[{"size":"x-small","type":"around"}],"sizeClass":"slds-size_12-of-12"},"type":"block"}],"class":"slds-col ","element":"block","elementLabel":"Block-0-Block-0-Block-2","key":"element_element_element_block_0_1_block_0_1_block_1_1","name":"Block","parentElementKey":"element_element_block_0_1_block_0_1","property":{"card":"{card}","collapsedByDefault":false,"collapsible":false,"data-conditions":{"group":[],"id":"state-condition-object","isParent":true},"label":"Block","record":"{record}"},"size":{"default":"12","isResponsive":false},"stateIndex":1,"styleObject":{"background":{"color":"","image":"","position":"","repeat":"","size":""},"border":{"color":"","radius":"","style":"","type":"","width":""},"class":"slds-p-around_small ","container":{"class":""},"elementStyleProperties":{},"inlineStyle":"","margin":[],"padding":[{"label":"around:small","size":"small","type":"around"}],"size":{"default":"12","isResponsive":false},"sizeClass":"slds-size_12-of-12 ","style":"             ","text":{"align":"","color":""}},"type":"block"}],"class":"slds-col ","element":"block","elementLabel":"Block-0-Block-0","key":"element_element_block_0_1_block_0_1","name":"Block","parentElementKey":"element_block_0_1","property":{"card":"{card}","collapsedByDefault":false,"collapsible":false,"label":"Block","record":"{record}"},"size":{"default":"12","isResponsive":false},"stateIndex":1,"styleObject":{"background":{"color":"","image":"","position":"","repeat":"","size":""},"border":{"color":"#f3f2f2","radius":"5px","style":"solid","type":"","width":"1"},"class":"","container":{"class":""},"elementStyleProperties":{},"inlineStyle":"","margin":[],"padding":[],"size":{"default":"12","isResponsive":false},"sizeClass":"slds-size_12-of-12 ","style":"     border-color:#f3f2f2; border-width:1px; border-radius:5px; border-style:solid;     ","text":{"align":"","color":""}},"type":"block"}],"class":"slds-col ","element":"block","elementLabel":"Block-0","name":"Block","property":{"card":"{card}","collapsedByDefault":false,"collapsible":false,"label":"Block","record":"{record}"},"size":{"default":"12","isResponsive":false},"stateIndex":1,"styleObject":{"background":{"color":"","image":"","position":"","repeat":"","size":""},"border":{"color":"#cccccc","radius":"","style":"","type":"","width":""},"class":"","container":{"class":""},"elementStyleProperties":{},"inlineStyle":"","margin":[],"padding":[],"size":{"default":"12","isResponsive":false},"sizeClass":"slds-size_12-of-12 ","style":"     border-color:#cccccc;        ","text":{"align":"","color":""}},"type":"block"}]}},"conditions":{"group":[],"id":"state-condition-object","isParent":true},"definedActions":{"actions":[]},"documents":[],"fields":[],"isSmartAction":false,"name":"Active","omniscripts":[],"smartAction":{},"styleObject":{"background":{"color":"","image":"","position":"","repeat":"","size":""},"border":{"color":"","radius":"","style":"","type":"","width":""},"class":"slds-card slds-grid slds-p-around_x-small slds-m-around_none ","container":{"class":"slds-card slds-grid"},"elementStyleProperties":{},"inlineStyle":"","margin":[{"label":"around:none","size":"none","type":"around"}],"padding":[{"label":"around:x-small","size":"x-small","type":"around"}],"size":{"default":"12","isResponsive":false},"sizeClass":"slds-size_12-of-12 ","style":"             ","text":{"align":"","color":""}}}],"theme":"slds","title":"CON_UpcomingVisits","xmlObject":{"apiVersion":48,"isExplicitImport":false,"masterLabel":"CON_UpcomingVisits","runtimeNamespace":"vlocity_cmt","targetConfigs":"PHRhcmdldENvbmZpZyB0YXJnZXRzPSJsaWdodG5pbmdDb21tdW5pdHlfX0RlZmF1bHQiPg0KICAgICAgPHByb3BlcnR5IG5hbWU9InJlY29yZElkIiB0eXBlPSJTdHJpbmciLz4NCiAgICA8L3RhcmdldENvbmZpZz4=","targets":{"target":["lightning__AppPage","lightning__HomePage","lightning__RecordPage","lightningCommunity__Page","lightningCommunity__Default"]}},"Id":"a5p8G00000000C5QAI","vlocity_cmt__GlobalKey__c":"CON_UpcomingVisits/GoogleFiber/1/1628238686771","vlocity_cmt__IsChildCard__c":true};
  export default definition