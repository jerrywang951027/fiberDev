let definition =
      {"states":[{"fields":[],"conditions":{"id":"state-condition-object","isParent":true,"group":[]},"definedActions":{"actions":[]},"name":"Active","isSmartAction":false,"smartAction":{},"styleObject":{"padding":[{"type":"around","size":"x-small"}],"margin":[{"type":"bottom","size":"x-small"}],"container":{"class":"slds-card"},"size":{"isResponsive":false,"default":"12"},"sizeClass":"slds-size_12-of-12","class":"slds-card slds-p-around_x-small slds-m-bottom_x-small"},"components":{"layer-0":{"children":[{"name":"Block","element":"block","size":{"isResponsive":false,"default":"12"},"stateIndex":0,"class":"slds-col ","property":{"label":"Block","collapsible":false,"record":"{record}","collapsedByDefault":false,"card":"{card}"},"type":"block","styleObject":{"padding":[{"type":"around","size":"x-small"}],"class":"slds-p-around_x-small","sizeClass":"slds-size_12-of-12"},"children":[{"key":"element_element_block_0_0_flexIcon_0_0","name":"Icon","element":"flexIcon","size":{"isResponsive":false,"default":"1"},"stateIndex":0,"class":"slds-col ","property":{"record":"{record}","iconType":"Salesforce SVG","iconName":"standard:custom_notification","size":"small","extraclass":"slds-icon-standard-custom-notification","variant":"inverse","imgsrc":""},"type":"element","styleObject":{"sizeClass":"slds-size_1-of-12 ","size":{"isResponsive":false,"default":"1"},"padding":[],"margin":[],"background":{"color":"","image":"","size":"","repeat":"","position":""},"container":{"class":""},"border":{"type":"","width":"","color":"","radius":"","style":""},"elementStyleProperties":{},"text":{"align":"center","color":""},"inlineStyle":"","class":"slds-text-align_center ","style":"     : #ccc 1px solid; \n         "},"parentElementKey":"element_block_0_0","elementLabel":"Block-0-Icon-0"},{"key":"element_element_block_0_0_outputField_1_0","name":"Text","element":"outputField","size":{"isResponsive":false,"default":"11"},"stateIndex":0,"class":"slds-col ","property":{"record":"{record}","mergeField":"%3Cdiv%3E%3Cstrong%3E%3Cspan%20style=%22font-size:%2012pt;%22%3ETicket%20Actions%3C/span%3E%3C/strong%3E%3C/div%3E","card":"{card}"},"type":"text","styleObject":{"sizeClass":"slds-size_11-of-12 ","padding":[],"margin":[],"background":{"color":"","image":"","size":"","repeat":"","position":""},"size":{"isResponsive":false,"default":"11"},"container":{"class":""},"border":{"type":"","width":"","color":"","radius":"","style":""},"elementStyleProperties":{},"text":{"align":"","color":""},"inlineStyle":"","class":"","style":"     : #ccc 1px solid; \n         "},"parentElementKey":"element_block_0_0","elementLabel":"Block-0-Text-1"}],"elementLabel":"Block-0"},{"name":"Action","element":"action","size":{"isResponsive":false,"default":"12"},"stateIndex":0,"class":"slds-col ","property":{"stateObj":"{record}","card":"{card}","record":"{record}","stateAction":{"id":"flex-action-1636981962317","type":"Custom","displayName":"Go To CSA","vlocityIcon":"","openUrlIn":"New Tab/Window","hasExtraParams":true,"targetType":"Web Page","Web Page":{"targetName":"https://fiber-customer-support-staging.corp.google.com/Legacy/BugafiberTicket?ticket_id={bugafiberId}"}},"reRenderFlyout":true,"displayAsButton":false,"data-conditions":{"id":"state-condition-object","isParent":true,"group":[]},"buttonVariant":"brand","styles":{"label":{"textAlign":"center","fontSize":"","color":"#ffffff"}}},"type":"element","styleObject":{"sizeClass":"slds-size_12-of-12 ","size":{"isResponsive":false,"default":"12"},"padding":[{"type":"top","size":"xx-small","label":"top:xx-small"}],"margin":[{"type":"bottom","size":"x-small","label":"bottom:x-small"}],"background":{"color":"#0176d3","image":"","size":"","repeat":"","position":""},"container":{"class":""},"border":{"type":["border_top","border_right","border_bottom","border_left"],"width":"1","color":"#dddbda","radius":"5px","style":"solid"},"elementStyleProperties":{"styles":{"label":{"textAlign":"center","fontSize":"","color":"#ffffff"}}},"text":{"align":"","color":""},"inlineStyle":"","class":"slds-border_top slds-border_right slds-border_bottom slds-border_left slds-p-top_xx-small slds-m-bottom_x-small ","style":"background-color:#0176d3;     border-top: #dddbda 1px solid;border-right: #dddbda 1px solid;border-bottom: #dddbda 1px solid;border-left: #dddbda 1px solid; \n    border-radius:5px;     "},"elementLabel":"goToCSA","userUpdatedElementLabel":true},{"name":"Action","element":"action","size":{"isResponsive":false,"default":"12"},"stateIndex":0,"class":"slds-col ","property":{"stateObj":"{record}","card":"{card}","record":"{record}","stateAction":{"id":"flex-action-1636720397418","type":"Flyout","displayName":"Configure Order","vlocityIcon":"","openUrlIn":"New Tab/Window","hasExtraParams":true,"flyoutType":"OmniScripts","openFlyoutIn":"Modal","osName":"CON/InflightOrderDetails/English","flyoutLwc":"c-o-n-inflight-order-details-english","layoutType":"lightning","flyoutParams":{"ticketId":"{recordId}"}},"reRenderFlyout":true,"displayAsButton":false,"data-conditions":{"id":"state-condition-object","isParent":true,"group":[]},"buttonVariant":"brand","styles":{"label":{"textAlign":"center","fontSize":"","color":"#ffffff"}}},"type":"element","styleObject":{"sizeClass":"slds-size_12-of-12 ","size":{"isResponsive":false,"default":"12"},"padding":[{"type":"top","size":"xx-small","label":"top:xx-small"}],"margin":[{"type":"bottom","size":"x-small","label":"bottom:x-small"}],"background":{"color":"#0176d3","image":"","size":"","repeat":"","position":""},"container":{"class":""},"border":{"type":["border_top","border_right","border_bottom","border_left"],"width":"1","color":"#dddbda","radius":"5px","style":"solid"},"elementStyleProperties":{"styles":{"label":{"textAlign":"center","fontSize":"","color":"#ffffff"}}},"text":{"align":"","color":""},"inlineStyle":"","class":"slds-border_top slds-border_right slds-border_bottom slds-border_left slds-p-top_xx-small slds-m-bottom_x-small ","style":"background-color:#0176d3;     border-top: #dddbda 1px solid;border-right: #dddbda 1px solid;border-bottom: #dddbda 1px solid;border-left: #dddbda 1px solid; \n    border-radius:5px;     "},"elementLabel":"Action-1-clone-0","userUpdatedElementLabel":true},{"name":"Action","element":"action","size":{"isResponsive":false,"default":"12"},"stateIndex":0,"class":"slds-col ","property":{"stateObj":"{record}","card":"{card}","record":"{record}","stateAction":{"id":"flex-action-1634055715340","type":"Flyout","displayName":"Reschedule","vlocityIcon":"","openUrlIn":"Current Window","flyoutType":"OmniScripts","openFlyoutIn":"Modal","layoutType":"lightning","osName":"TCK/RescheduleAppointment/English","flyoutLwc":"t-c-k-reschedule-appointment-english","hasExtraParams":true,"flyoutParams":{"ContextId":"{recordId}"}},"reRenderFlyout":true,"displayAsButton":false,"data-conditions":{"id":"state-condition-object","isParent":true,"group":[{"id":"state-new-condition-134","field":"isValue","operator":"==","value":"true","type":"custom"}]},"buttonVariant":"brand","styles":{"label":{"textAlign":"center","fontSize":"","color":"#ffffff"}}},"type":"element","styleObject":{"sizeClass":"slds-size_12-of-12 ","size":{"isResponsive":false,"default":"12"},"padding":[{"type":"top","size":"xx-small","label":"top:xx-small"}],"margin":[{"type":"bottom","size":"x-small","label":"bottom:x-small"}],"background":{"color":"#0176d3","image":"","size":"","repeat":"","position":""},"container":{"class":""},"border":{"type":["border_top","border_right","border_bottom","border_left"],"width":"1","color":"#dddbda","radius":"5px","style":"solid"},"elementStyleProperties":{"styles":{"label":{"textAlign":"center","fontSize":"","color":"#ffffff"}}},"text":{"align":"","color":""},"inlineStyle":"","class":"slds-border_top slds-border_right slds-border_bottom slds-border_left slds-p-top_xx-small slds-m-bottom_x-small ","style":"background-color:#0176d3;     border-top: #dddbda 1px solid;border-right: #dddbda 1px solid;border-bottom: #dddbda 1px solid;border-left: #dddbda 1px solid; \n    border-radius:5px;     "},"elementLabel":"Action-3"},{"name":"Action","element":"action","size":{"isResponsive":false,"default":"12"},"stateIndex":0,"class":"slds-col ","property":{"stateObj":"{record}","card":"{card}","record":"{record}","stateAction":{"id":"flex-action-1629383748831","type":"Flyout","displayName":"Close Work","vlocityIcon":"","openUrlIn":"Current Window","flyoutType":"OmniScripts","openFlyoutIn":"Modal","layoutType":"lightning","osName":"TCK/CloseWork/English","flyoutLwc":"t-c-k-close-work-english","hasExtraParams":true,"flyoutParams":{"ContextId":"{recordId}"}},"reRenderFlyout":true,"displayAsButton":false,"data-conditions":{"id":"state-condition-object","isParent":true,"group":[]},"buttonVariant":"brand","styles":{"label":{"textAlign":"center","color":"#ffffff"}}},"type":"element","styleObject":{"sizeClass":"slds-size_12-of-12 ","size":{"isResponsive":false,"default":"12"},"padding":[{"type":"top","size":"xx-small","label":"top:xx-small"}],"margin":[{"type":"bottom","size":"x-small","label":"bottom:x-small"}],"background":{"color":"#0176d3","image":"","size":"","repeat":"","position":""},"container":{"class":""},"border":{"type":["border_top","border_right","border_bottom","border_left"],"width":"1","color":"#dddbda","radius":"5px","style":"solid"},"elementStyleProperties":{"styles":{"label":{"textAlign":"center","color":"#ffffff"}}},"text":{"align":"","color":""},"inlineStyle":"","class":"slds-border_top slds-border_right slds-border_bottom slds-border_left slds-p-top_xx-small slds-m-bottom_x-small ","style":"background-color:#0176d3;     border-top: #dddbda 1px solid;border-right: #dddbda 1px solid;border-bottom: #dddbda 1px solid;border-left: #dddbda 1px solid; \n    border-radius:5px;     "},"elementLabel":"Action-5"},{"name":"Action","element":"action","size":{"isResponsive":false,"default":"12"},"stateIndex":0,"class":"slds-col ","property":{"stateObj":"{record}","card":"{card}","record":"{record}","stateAction":{"id":"flex-action-1635003685156","type":"Flyout","displayName":"Escalate Ticket","vlocityIcon":"","openUrlIn":"Current Window","flyoutType":"OmniScripts","openFlyoutIn":"Modal","layoutType":"lightning","osName":"TCK/EscalateService/English","flyoutLwc":"t-c-k-escalate-service-english","hasExtraParams":true,"flyoutParams":{"ContextId":"{recordId}"}},"reRenderFlyout":true,"displayAsButton":false,"data-conditions":{"id":"state-condition-object","isParent":true,"group":[{"id":"state-new-condition-150","field":"isValue","operator":"==","value":"true","type":"custom"}]},"buttonVariant":"brand","styles":{"label":{"textAlign":"center","color":"#ffffff"}}},"type":"element","styleObject":{"sizeClass":"slds-size_12-of-12 ","size":{"isResponsive":false,"default":"12"},"padding":[{"type":"top","size":"xx-small","label":"top:xx-small"}],"margin":[{"type":"bottom","size":"x-small","label":"bottom:x-small"}],"background":{"color":"#0176d3","image":"","size":"","repeat":"","position":""},"container":{"class":""},"border":{"type":["border_top","border_right","border_bottom","border_left"],"width":"1","color":"#dddbda","radius":"5px","style":"solid"},"elementStyleProperties":{"styles":{"label":{"textAlign":"center","color":"#ffffff"}}},"text":{"align":"","color":""},"inlineStyle":"","class":"slds-border_top slds-border_right slds-border_bottom slds-border_left slds-p-top_xx-small slds-m-bottom_x-small ","style":"background-color:#0176d3;     border-top: #dddbda 1px solid;border-right: #dddbda 1px solid;border-bottom: #dddbda 1px solid;border-left: #dddbda 1px solid; \n    border-radius:5px;     "},"elementLabel":"Action-5-clone-0"},{"name":"Action","element":"action","size":{"isResponsive":false,"default":"12"},"stateIndex":0,"class":"slds-col ","property":{"stateObj":"{record}","card":"{card}","record":"{record}","stateAction":{"id":"flex-action-1628606605990","type":"Flyout","displayName":"Cancel Ticket","vlocityIcon":"","openUrlIn":"Current Window","flyoutType":"OmniScripts","openFlyoutIn":"Modal","layoutType":"lightning","osName":"TCK/CancelTicket/English","flyoutLwc":"t-c-k-cancel-ticket-english","hasExtraParams":true,"flyoutParams":{"ContextId":"{recordId}"}},"reRenderFlyout":true,"displayAsButton":false,"data-conditions":{"id":"state-condition-object","isParent":true,"group":[]},"buttonVariant":"brand","styles":{"label":{"textAlign":"center","color":"#ffffff"}}},"type":"element","styleObject":{"sizeClass":"slds-size_12-of-12 ","size":{"isResponsive":false,"default":"12"},"padding":[{"type":"top","size":"xx-small","label":"top:xx-small"}],"margin":[{"type":"bottom","size":"x-small","label":"bottom:x-small"}],"background":{"color":"#0176d3","image":"","size":"","repeat":"","position":""},"container":{"class":"slds-card"},"border":{"type":["border_top","border_right","border_bottom","border_left"],"width":"1","color":"#dddbda","radius":"5px","style":"solid"},"elementStyleProperties":{"styles":{"label":{"textAlign":"center","color":"#ffffff"}}},"text":{"align":"","color":""},"inlineStyle":"","class":"slds-card slds-border_top slds-border_right slds-border_bottom slds-border_left slds-p-top_xx-small slds-m-bottom_x-small ","style":"background-color:#0176d3;     border-top: #dddbda 1px solid;border-right: #dddbda 1px solid;border-bottom: #dddbda 1px solid;border-left: #dddbda 1px solid; \n    border-radius:5px;     "},"elementLabel":"Action-5-clone-0"}]}},"childCards":[],"actions":[],"omniscripts":[{"type":"CON","subtype":"InflightOrderDetails","language":"English"},{"type":"TCK","subtype":"RescheduleAppointment","language":"English"},{"type":"TCK","subtype":"CloseWork","language":"English"},{"type":"TCK","subtype":"EscalateService","language":"English"},{"type":"TCK","subtype":"CancelTicket","language":"English"}],"documents":[]}],"dataSource":{"type":"IntegrationProcedures","value":{"ipMethod":"TCK_ExtractProfileAndTicketDeatils","vlocityAsync":false,"inputMap":{"ticketId":"{recordId}","userId":"{userId}"},"resultVar":""},"orderBy":{"name":"","isReverse":false},"contextVariables":[{"name":"recordId","val":"x040n0000004e2AAAQ","id":62},{"name":"userId","val":"0050n000003dTgPAAU","id":22}]},"title":"TCK_OperationTicketActions","enableLwc":true,"isFlex":true,"theme":"slds","lwc":{"DeveloperName":"cfTCK_OperationTicketActions_12_GoogleFiber","Id":"0Rb0n000000914HCAQ","MasterLabel":"cfTCK_OperationTicketActions_12_GoogleFiber","NamespacePrefix":"c","ManageableState":"unmanaged"},"isRepeatable":true,"xmlObject":{"apiVersion":48,"isExplicitImport":false,"isExposed":true,"masterLabel":"TCK_OperationTicketActions","runtimeNamespace":"vlocity_cmt","targets":{"target":["lightning__AppPage","lightning__HomePage","lightningCommunity__Page","lightningCommunity__Default","lightning__RecordPage"]},"targetConfigs":"PHRhcmdldENvbmZpZyB0YXJnZXRzPSJsaWdodG5pbmdfX0FwcFBhZ2UiPg0KICAgICAgPHByb3BlcnR5IG5hbWU9ImRlYnVnIiB0eXBlPSJCb29sZWFuIi8+DQogICAgICA8cHJvcGVydHkgbmFtZT0icmVjb3JkSWQiIHR5cGU9IlN0cmluZyIvPg0KICAgIDwvdGFyZ2V0Q29uZmlnPg0KICAgIDx0YXJnZXRDb25maWcgdGFyZ2V0cz0ibGlnaHRuaW5nX19SZWNvcmRQYWdlIj4NCiAgICAgIDxwcm9wZXJ0eSBuYW1lPSJkZWJ1ZyIgdHlwZT0iQm9vbGVhbiIvPg0KICAgIDwvdGFyZ2V0Q29uZmlnPg0KICAgIDx0YXJnZXRDb25maWcgeG1sbnM9IiIgdGFyZ2V0cz0ibGlnaHRuaW5nQ29tbXVuaXR5X19EZWZhdWx0Ij4NCiAgICAgIDxwcm9wZXJ0eSBuYW1lPSJyZWNvcmRJZCIgdHlwZT0iU3RyaW5nIi8+DQogICAgPC90YXJnZXRDb25maWc+"},"Id":"a5p8G00000000MRQAY","vlocity_cmt__GlobalKey__c":"TCK_OperationTicketActions/GoogleFiber/12/1635419493213","vlocity_cmt__IsChildCard__c":false};
  export default definition