# Three and a Half Asians Inventory System API #

# Sessions API #
----------

## SESS-1: Login to a Session ##

### *POST /api/sessions* ###

### Brief Description ###
Creates an authentication token for a newcomer to the website. The authentication token is randomly generated and is associated with a user account. Further interaction with the user API requires use of the entered alphanumeric token as an Authorization header.

Parameter  	  | Description											| Data Type
------------- | -------------										| -------------
Email		  | User email address. **(Required)**					| String
Password	  | Password associated with user. **(Required)**		| String

### Response Messages ###
HTTP Status Code	| Reasons						
------------- 		| -------------						
200			  		| OK					
401					| Unauthorized
422	  				| Unprocessable Entity

### Sample Outputs ###

**Successful Login (200)**
```javascript
{
  id: 13,
  email: "exampleapproved-1@example.com",
  permission: "admin",
  authorization: "MRM_kQsq4TD61QRaVNN_"
}
```

**Incorrect Username/Password (422)**
```javascript
{
  errors: "Invalid username or password"
}
```

**Account has been deactivated (401)**
```javascript
{
  errors: "Your account has not been approved by an administrator"
}
```		

## SESS-2 Logout of a Session ##

### *GET /api/sessions/{id}* ###

### Brief Description ###
Removes your authorization token, creating a randomly generated alphanumerical token that is **not** shown as output.


Parameter  	  | Description							| Data Type
------------- | -------------						| -------------
Authorization | Authorization Token	**(Required)**	| Header/String

### Response Messages ###
HTTP Status Code	| Reasons						
------------- 		| -------------											
204					| No Content
422	  				| Unprocessable Entity

### Sample Outputs ###

**Successful Session Deletion (204)**
```javascript
no content
```

**Incorrect Authorization Token (422)**
```javascript
{
  errors: "Invalid authorization token"
}
```

# CustomFields API #
----------

## CF-1 Shows all or specified Custom Fields ##

### *GET /api/custom_fields* ###

### Brief Description ###
Queries all available custom fields if no query parameters specified. Otherwise, queries by query parameters.


Parameter  	  | Description												| Data Type
------------- | -------------											| -------------
Authorization | Authorization Token	**(Required)**						| Header/String
Field Name	  | Name of Custom Field *(Optional)*						| String
Private?	  | Determines if students may see this field *(Optional)* 	| Boolean
Field Type	  |	Content Type of Field *(Optional)*						| Enum *(see below)*

**Field Type** must be one of the following: `[short_text_type, long_text_type, integer_type, float_type]`

### Response Messages ###
HTTP Status Code	| Reasons						
------------- 		| -------------											
200					| OK
401					| Unauthorized
422	  				| Unprocessable Entity


### Sample Correct Input ###

![](http://i.imgur.com/iNU9Bi0.png)

### Sample Outputs ###

**Correct Query (200)**
```javascript
[
  {
    "id": 1,
    "field_name": "location",
    "private_indicator": false,
    "field_type": "short_text_type"
  }
]
```

## CF-2 Create Custom Fields ##

### *POST /api/custom_fields* ###

### Brief Description ###
Admins may create a new custom field that is available for all items to reference.

Parameter  	  					| Description												| Data Type
------------- 					| -------------												| -------------
Authorization 					| Authorization Token	**(Required)**						| Header/String
custom_field[field_name]		| Name of the Custom Field **(Required)**					| String
custom_field[private_indicator]	| Determines if students may see this field **(Required)**	| Boolean
custom_field[field_type]		| Content Type of Field **(Required)**						| Enum *(see below)*

**Field Type** must be one of the following: `[short_text_type, long_text_type, integer_type, float_type]`

### Response Messages ###
HTTP Status Code	| Reasons						
------------- 		| -------------											
201					| Created
401					| Unauthorized
422	  				| Unprocessable Entity

### Sample Correct Input ###

![](http://i.imgur.com/MESLBFs.png)

### Sample Outputs ###

**Successful Custom Field Creation (200)**
```javascript
{
  "id": 6,
  "field_name": "price",
  "private_indicator": true,
  "field_type": "float_type"
}
```
## CF-3 Deletes Custom Fields ##

### *DELETE /api/custom_fields/{id}* ###

### Brief Description ###
Admins may delete a custom field, also removing references to it by items.

Parameter  	  | Description								| Data Type
------------- | -------------							| -------------
Authorization | Authorization Token	**(Required)**		| Header/String
id			  | Custom Field ID	**(Required)**			| Integer

*Note:* Determining Custom Field ID for a custom field can be obtained by using *GET /api/custom_fields*

### Response Messages ###
HTTP Status Code	| Reasons						
------------- 		| -------------											
204					| No Content
401					| Unauthorized
404					| Not found
422	  				| Unprocessable Entity

### Sample Correct Input ###

![](http://i.imgur.com/HKpHmKt.png)

### Sample Outputs ###

**Successful CustomField Deletion (204)**
```javascript
no content
```

## CF-4 Fetches a specific Custom Field ##

### *GET /api/custom_fields/{id}* ###

### Brief Description ###
Admins/Managers may view any particular custom field. Students may only view public custom fields. Query by custom field id.

Parameter  	  | Description								| Data Type
------------- | -------------							| -------------
Authorization | Authorization Token	**(Required)**		| Header/String
id			  | Custom Field **(Required)**				| Integer

*Note:* Determining Custom Field ID for a custom field can be obtained by using *GET /api/custom_fields*

### Response Messages ###
HTTP Status Code	| Reasons						
------------- 		| -------------											
200					| OK
401					| Unauthorized
404					| Not found

### Sample Correct Input ###

![](http://i.imgur.com/xx4yIPH.png)

### Sample Outputs ###

**Successful Custom Field Fetch (200)**
```javascript
{
  "id": 1,
  "field_name": "location",
  "private_indicator": false,
  "field_type": "short_text_type"
}
```

## CF-5 Updates the name of a Custom Field ##

### *PUT/PATCH /api/custom_fields/{id}/update_name* ###

### Brief Description ###
Admins may change the name of a custom field using this API.


Parameter  	  				| Description								| Data Type
------------- 				| -------------								| -------------
Authorization 				| Authorization Token **(Required)**		| Header/String
id			  				| Custom Field ID **(Required)**			| Integer
custom_field[field_name]	| Updated Custom Field Name **(Required)**	| String

*Note:* Determining Custom Field ID for a custom field can be obtained by using *GET /api/custom_fields*

### Response Messages ###
HTTP Status Code	| Reasons						
------------- 		| -------------											
200					| OK
401					| Unauthorized
404					| Not found
422					| Unprocessable Entity

### Sample Correct Input ###

![](http://i.imgur.com/Uem6iLJ.png)

### Sample Outputs ###

**Successful CustomField Name Update (200)**
```javascript
{
  "id": 7,
  "field_name": "modified_test_field_name",
  "private_indicator": true,
  "field_type": "float_type"
}
```

## CF-6 Updates the privacy of a CustomField ##

### *PUT/PATCH /api/custom_fields/{id}/update_privacy* ###

### Brief Description ###
Admins may change the privacy of a custom field.


Parameter  	  					| Description										| Data Type
------------- 					| -------------										| -------------
Authorization 					| Authorization Token **(Required)**				| Header/String
id			  					| Custom Field ID **(Required)**					| Integer
custom_field[private_indicator]	| Is Updated Custom Field 'Private'? **(Required)**	| Boolean

*Note:* Determining Custom Field ID for a custom field can be obtained by using *GET /api/custom_fields*

### Response Messages ###
HTTP Status Code	| Reasons						
------------- 		| -------------											
200					| OK
401					| Unauthorized
404					| Not found
422					| Unprocessable Entity

### Sample Correct Input ###

![](http://i.imgur.com/GSnp6r5.png)

### Sample Outputs ###

**Successful Custom Field Type Update (200)**
```javascript
{
  "id": 7,
  "private_indicator": false,
  "field_name": "modified_test_field_name",
  "field_type": "float_type"
}
```

## CF-7 Updates the type of a CustomField ##

### *PUT/PATCH /api/custom_fields/{id}/update_type* ###

### Brief Description ###
Admins may change the type of a custom field. When the type of custom field is changed, then all associated field contents for items are also cleared.


Parameter  	  				| Description							| Data Type
------------- 				| -------------							| -------------
Authorization 				| Authorization Token **(Required)**	| Header/String
id			  				| Custom Field ID **(Required)**		| Integer
custom_field[field_type]	| Custom Field Type **(Required)** 		| Enum *(see below)*

**Field Type** must be one of the following: `[short_text_type, long_text_type, integer_type, float_type]`

*Note:* Determining Custom Field ID for a custom field can be obtained by using *GET /api/custom_fields*

### Response Messages ###
HTTP Status Code	| Reasons						
------------- 		| -------------											
200					| OK
401					| Unauthorized
404					| Not found
422					| Unprocessable Entity

### Sample Correct Input ###

![](http://i.imgur.com/p44dcbz.png)

### Sample Outputs ###

**Successful CustomField Type Update (200)**
```javascript
{
  "id": 7,
  "field_type": "short_text_type",
  "field_name": "modified_test_field_name",
  "private_indicator": false
}
```

# Tags API #
----------

## TAG-1 Obtains all or query-specified tags ##

### *GET /api/tags* ###

### Brief Description ###
Obtains all currently defined tags. Can also query based on tag name.


Parameter  	  | Description							| Data Type
------------- | -------------						| -------------
Authorization | Authorization Token **(Required)**	| Header/String
name		  |	Tag Name *(Optional)*				| String

### Response Messages ###
HTTP Status Code	| Reasons						
------------- 		| -------------											
200					| OK
401					| Unauthorized

### Sample Correct Input ###

![](http://i.imgur.com/IXXwgL0.png)

### Sample Outputs ###

**Successful Searching Tags (200)**
```javascript
[
  {
    "id": 8,
    "name": "test_tag1",
    "created_at": "2017-03-28T00:37:45.502-04:00",
    "updated_at": "2017-03-28T00:37:45.502-04:00"
  }
]
```

## TAG-2 Create a new tag ##

### *POST /api/tags* ###

### Brief Description ###
Admins may create their own tags for later associations with items


Parameter  	  | Description							| Data Type
------------- | -------------						| -------------
Authorization | Authorization Token **(Required)**	| Header/String
name		  |	Tag Name **(Required)**				| String

### Response Messages ###
HTTP Status Code	| Reasons						
------------- 		| -------------											
200					| OK
401					| Unauthorized

### Sample Correct Input ###

![](http://i.imgur.com/tk8LIqy.png)

### Sample Outputs ###

**Create New Tags (200)**
```javascript
{
  "id": 11,
  "name": "monster",
  "created_at": "2017-03-28T01:26:45.649-04:00",
  "updated_at": "2017-03-28T01:26:45.649-04:00"
}

```

## TAG-3 Delete a tag ##

### *DELETE /api/tags/{:id}* ###

### Brief Description ###
Admins may delete tags. Deletes all associations of tags with items as well.


Parameter  	  | Description							| Data Type
------------- | -------------						| -------------
Authorization | Authorization Token **(Required)**	| Header/String
id			  |	Tags ID **(Required)**				| Integer

*Note:* Determining Tag ID for a tag can be obtained by using *GET /api/tags*

### Response Messages ###
HTTP Status Code	| Reasons						
------------- 		| -------------											
204					| No Content
401					| Unauthorized
404 				| Not Found

### Sample Correct Input ###

![](http://i.imgur.com/wf81y0g.png)

### Sample Outputs ###
**Successful Tag Deletion (204)**
```javascript
no content
```

## TAG-4 Obtain a specific tag ##

### *SHOW /api/tags/{:id}* ###

### Brief Description ###
Obtains a specific tag based on tag id.


Parameter  	  | Description							| Data Type
------------- | -------------						| -------------
Authorization | Authorization Token **(Required)**	| Header/String
id			  |	Tags ID **(Required)**				| String

*Note:* Determining Tag ID for a tag can be obtained by using *GET /api/tags*

### Response Messages ###
HTTP Status Code	| Reasons						
------------- 		| -------------											
200					| OK
401					| Unauthorized
404 				| Not Found

### Sample Correct Input ###

![](http://i.imgur.com/yRRaJd9.png)

### Sample Outputs ###
**Successful Tag Fetch (200)**
```javascript
{
  "id": 1,
  "name": "ECE110",
  "created_at": "2017-03-27T18:12:05.934-04:00",
  "updated_at": "2017-03-27T18:12:05.934-04:00"
}
```

## TAG-5 Update a specific tag ##

### *PUT/PATCH /api/tags/{:id}* ###

### Brief Description ###
Admins can change the name of existing tags. Checks privilege.


Parameter  	  | Description							| Data Type
------------- | -------------						| -------------
Authorization | Authorization Token **(Required)**	| Header/String
id			  |	Tags ID **(Required)**				| String
tag[name]	  | Update Tag Name **(Required)**		| String

*Note:* Determining Tag ID for a tag can be obtained by using *GET /api/tags*

### Response Messages ###
HTTP Status Code	| Reasons						
------------- 		| -------------											
200					| OK
401					| Unauthorized
404 				| Not Found

### Sample Correct Input ###

![](http://i.imgur.com/sPYDDc3.png)

### Sample Outputs ###
**Successful Tag Fetch (200)**
```javascript
{
  "id": 7,
  "name": "updated_tag_name",
  "created_at": "2017-03-28T00:37:45.474-04:00",
  "updated_at": "2017-03-28T01:44:11.012-04:00"
}
```

# Users API #
----------

## USERS-1 Update Password ##

### *PUT/PATCH /api/users/{id}/update_password* ###

### Brief Description ###
Updates your own password. Your new password goes in user[password]. There must also be a confirmation of the password.

Parameter  	  				| Description									| Data Type
------------- 				| -------------									| -------------
Authorization 				| Authorization Token **(Required)**			| Header/String
id			  				|	User ID **(Required)**						| Integer
user[password]	  			| Updated Password **(Required)**				| String
user[password_confirmation]	| Updated Password Confirmation **(Required)**	| String

*Note:* Determining User ID for a user can be obtained by using *GET /api/users*

### Response Messages ###
HTTP Status Code	| Reasons						
------------- 		| -------------											
200					| OK
401					| Unauthorized
404 				| Not Found
422					| Unprocessable Entity

### Sample Correct Input ###

![](http://i.imgur.com/blJxPKw.png)

### Sample Outputs ###
**Successful Password Update (200)**
```javascript
{
  "message": "Password Updated!"
}
```

## USERS-2 Update Status ##

### *PUT/PATCH /api/users/{id}/update_status* ###

### Brief Description ###
Admins may activate or deactive a particular user from using the system. The ID of the user can be obtained using *GET /api/users*.

Parameter  	  				| Description									| Data Type
------------- 				| -------------									| -------------
Authorization 				| Authorization Token **(Required)**			| Header/String
id			  				| User ID **(Required)**						| Integer
user[status]	  			| Updated Status of User **(Required)**			| Enum *(see below)*

**Status** must be one of the following: `[approved, deactivated]`

*Note:* Determining User ID for a user can be obtained by using *GET /api/users*

### Response Messages ###
HTTP Status Code	| Reasons						
------------- 		| -------------											
200					| OK
401					| Unauthorized
404 				| Not Found
422					| Unprocessable Entity

### Sample Correct Input ###

![](http://i.imgur.com/R6mK7T1.png)

### Sample Outputs ###
**Successful Status Update (200)**
```javascript
{
  "id": 1,
  "email": "example-1@example.com",
  "status": "approved",
  "permission": "admin"
}
```

## USERS-3 Update Privilege ##

### *PUT/PATCH /api/users/{id}/update_privilege* ###

### Brief Description ###
Admins may update the privilege of any user except themselves.

Parameter  	  				| Description									| Data Type
------------- 				| -------------									| -------------
Authorization 				| Authorization Token **(Required)**			| Header/String
id			  				| User ID **(Required)**						| Integer
user[privilege]	  			| Updated Privilege of User **(Required)**		| Enum *(see below)*

**Privilege** must be one of the following: `[student, manager, admin]`

*Note:* Determining User ID for a user can be obtained by using *GET /api/users*

### Response Messages ###
HTTP Status Code	| Reasons						
------------- 		| -------------											
200					| OK
401					| Unauthorized
404 				| Not Found
422					| Unprocessable Entity

### Sample Correct Input ###

![](http://i.imgur.com/eBZCBnr.png)

### Sample Outputs ###
**Successful Privilege Update (200)**
```javascript
{
  "id": 1,
  "email": "example-1@example.com",
  "status": "approved",
  "permission": "manager"
}
```

## USERS-4 Return all Users ##

### *GET /api/users/index* ###

### Brief Description ###
Managers can view all users as well as filtered users. Managers are able to optionally filter by: email, status, and privilege.

Parameter  	  				| Description									| Data Type
------------- 				| -------------									| -------------
Authorization 				| Authorization Token **(Required)**			| Header/String
email			  			| Search by exact Email *(Optional)*			| String
status	  					| Search by status *(Optional)*					| Enum *(see below)*
privilege					| Search by privilege *(Optional)*				| Enum *(see below)*


**Status** must be one of the following: `[approved, deactivated]`

**Privilege** must be one of the following: `[student, manager, admin]`

### Response Messages ###
HTTP Status Code	| Reasons						
------------- 		| -------------											
200					| OK
401					| Unauthorized
404 				| Not Found
422					| Unprocessable Entity

### Sample Correct Input ###

![](http://i.imgur.com/5vHacmM.png)

### Sample Outputs ###
**Successful User Index Fetch (200)**
```javascript
[
  {
    "id": 25,
    "email": "adminusername@example.com",
    "status": "approved",
    "permission": "admin"
  }
]
```

## USERS-5 Create a local user ##

### *POST /api/users* ###

### Brief Description ###
Administrators can create local users (Non-NETID)

Parameter  	  				| Description										| Data Type
------------- 				| -------------										| -------------
Authorization 				| Authorization Token **(Required)**				| Header/String
user[username]			  	| New User's Username **(Required)**				| String
user[email]	  				| New User's Email **(Required)**					| String
user[password]				| New User's Password **(Required)**				| String
user[password_confirmation]	| New User's Password Confirmation **(Required)**	| String
user[privilege]				| New User's Privilege **(Required)**				| Enum *(see below)*
user[status]				| New User's Status *(Optional)*					| Enum *(see below)*

**Status** must be one of the following: `[approved, deactivated]`. By default it is 'approved'.

**Privilege** must be one of the following: `[student, manager, admin]`

### Response Messages ###
HTTP Status Code	| Reasons						
------------- 		| -------------											
200					| OK
401					| Unauthorized
404 				| Not Found
422					| Unprocessable Entity

### Sample Correct Input ###

![](http://i.imgur.com/ketuDe4.png)

### Sample Outputs ###
**Successful User Creation (200)**
```javascript
{
  "id": 37,
  "email": "test_email@example.com",
  "status": "approved",
  "permission": "student"
}
```

## USERS-6 Delete User ##

### *DELETE /api/users/{id}* ###

### Brief Description ###
Administrators can delete local users' accounts

Parameter  	  				| Description										| Data Type
------------- 				| -------------										| -------------
Authorization 				| Authorization Token **(Required)**				| Header/String
id			  				| User ID **(Required)**							| Integer

*Note:* Determining User ID for a user can be obtained by using *GET /api/users*

### Response Messages ###
HTTP Status Code	| Reasons						
------------- 		| -------------											
204					| No Content
401					| Unauthorized
404 				| Not Found

### Sample Correct Input ###

![](http://i.imgur.com/BpRFLJK.png)

### Sample Outputs ###
**Successful User Deletion (204)**
```javascript
no content
```

## USERS-7 Show Particular User by ID ##

### *SHOW /api/users/{id}* ###

### Brief Description ###
Managers can view specific users by their ID. Students can only view themselves.

Parameter  	  				| Description										| Data Type
------------- 				| -------------										| -------------
Authorization 				| Authorization Token **(Required)**				| Header/String
id			  				| User ID **(Required)**							| Integer

*Note:* Determining User ID for a user can be obtained by using *GET /api/users*

### Response Messages ###
HTTP Status Code	| Reasons						
------------- 		| -------------											
200					| OK
401					| Unauthorized
404 				| Not Found

### Sample Correct Input ###

![](http://i.imgur.com/oS1IKo0.png)

### Sample Outputs ###
**Successful Individual User Fetch (200)**
```javascript
{
  "id": 1,
  "email": "example-1@example.com",
  "status": "approved",
  "permission": "manager"
}
```

# Items API #
----------

## ITEMS-1 Create tags association for an item ##

### *POST /api/items/{id}/create_tag_associations* ###

### Brief Description ###
Based on an inputted list of tag names, associates all tag names listed to a item.

Parameter  	  				| Description										| Data Type
------------- 				| -------------										| -------------
Authorization 				| Authorization Token **(Required)**				| Header/String
id						  	| Item ID **(Required)**							| Integer
tag_names	  				| List of tag names *(Optional)*					| Comma Deliminated Strings

*Note:* Determining Item ID for an item can be obtained by using *GET /api/items*

### Response Messages ###
HTTP Status Code	| Reasons						
------------- 		| -------------											
200					| OK
401					| Unauthorized
404 				| Not Found
422					| Unprocessable Entity

### Sample Correct Input ###

![](http://i.imgur.com/qrLqhru.png)

### Sample Outputs ###
**Successful Tag Item Creation (200)**
```javascript
{
  "name": "Resistor",
  "quantity": 9001,
  "description": "Cognomen ut tantillus consectetur. Comedo voco vitae creo caelum vulpes corporis tempore.",
  "model_number": "183835",
  "tags": [
    {
      "id": 1,
      "name": "ECE110",
      "created_at": "2017-03-27T18:12:05.934-04:00",
      "updated_at": "2017-03-27T18:12:05.934-04:00"
    }
  ]
}
```

## ITEMS-2 Destroys tags association for an item ##

### *DELETE /api/items/{id}/destroy_tag_associations* ###

### Brief Description ###
Deletes either all tag associations for an item, or a specified list of tags. If tag_names is empty, then all tag associations are deleted.

Parameter  	  				| Description										| Data Type
------------- 				| -------------										| -------------
Authorization 				| Authorization Token **(Required)**				| Header/String
id						  	| Item ID **(Required)**							| Integer
tag_names	  				| List of tag names *(Optional)*					| Comma Deliminated Strings

*Note:* Determining Item ID for an item can be obtained by using *GET /api/items*

### Response Messages ###
HTTP Status Code	| Reasons						
------------- 		| -------------											
200					| OK
401					| Unauthorized
404 				| Not Found
422					| Unprocessable Entity

### Sample Correct Input ###

![](http://i.imgur.com/G78BNAE.png)

### Sample Outputs ###
**Successful Item-Tag association destruction (200)**
```javascript
{
  "name": "Resistor",
  "quantity": 82,
  "description": "Cognomen ut tantillus consectetur. Comedo voco vitae creo caelum vulpes corporis tempore.",
  "model_number": "183835",
  "tags": []
}
```

## ITEMS-3 Updates the general attributes of an item ##

### *PUT/PATCH /api/items/{id}/update_general* ###

### Brief Description ###
Updates the general attributes of an item (item name, description, and model number). Each are optional to update, and if all fields are empty, the item just simply doesn't update.


Parameter  	  				| Description										| Data Type
------------- 				| -------------										| -------------
Authorization 				| Authorization Token **(Required)**				| Header/String
id						  	| Item ID **(Required)**							| Integer
item[unique_name]			| Item Name *(Optional)*							| String
item[description]			| Item Description *(Optional)*						| String
item[model_number]			| Item Model Number *(Optional)*					| String

*Note:* Determining Item ID for an item can be obtained by using *GET /api/items*

### Response Messages ###
HTTP Status Code	| Reasons						
------------- 		| -------------											
200					| OK
401					| Unauthorized
404 				| Not Found
422					| Unprocessable Entity

### Sample Correct Input ###

![](http://i.imgur.com/ketuDe4.png)

### Sample Outputs ###
**Successful Item Update (200)**
```javascript
{
  "name": "Servo Motor",
  "quantity": 114,
  "description": "It goes fast",
  "model_number": "P90x",
  "tags": [],
  "requests": [
    {
      "request_id": 79,
      "user_id": 8,
      "status": "outstanding"
    },
    {
      "request_id": 77,
      "user_id": 9,
      "status": "outstanding"
    },
    {
      "request_id": 62,
      "user_id": 14,
      "status": "outstanding"
    },
    {
      "request_id": 46,
      "user_id": 29,
      "status": "cancelled"
    },
    {
      "request_id": 45,
      "user_id": 13,
      "status": "outstanding"
    },
    {
      "request_id": 37,
      "user_id": 5,
      "status": "outstanding"
    },
    {
      "request_id": 35,
      "user_id": 2,
      "status": "outstanding"
    }
  ],
  "custom_fields": [
    {
      "key": "modified_test_field_name",
      "value": null,
      "type": "short_text_type"
    },
    {
      "key": "location",
      "value": null,
      "type": "short_text_type"
    },
    {
      "key": "restock_info",
      "value": null,
      "type": "long_text_type"
    },
    {
      "key": "broken",
      "value": null,
      "type": "integer_type"
    },
    {
      "key": "# of times whatever",
      "value": null,
      "type": "integer_type"
    }
  ]
}
```

## ITEMS-4 Administrator fixes for item quantity ##

### *PUT/PATCH /api/items/{id}/fix_quantity* ###

### Brief Description ###
Allows administrators to fix general workflow errors associated with quantities of items.

Parameter  	  				| Description										| Data Type
------------- 				| -------------										| -------------
Authorization 				| Authorization Token **(Required)**				| Header/String
id						  	| Item ID **(Required)**							| Integer
item[quantity]				| Item Quantity **(Required)**						| Integer

*Note:* Determining Item ID for an item can be obtained by using *GET /api/items*

### Response Messages ###
HTTP Status Code	| Reasons						
------------- 		| -------------											
200					| OK
401					| Unauthorized
404 				| Not Found
422					| Unprocessable Entity

### Sample Correct Input ###

![](http://i.imgur.com/ZFUB4yR.png)

### Sample Outputs ###
**Successful Quantity Fix (200)**
```javascript
{
  "name": "Resistor",
  "quantity": 9001,
  "description": "Cognomen ut tantillus consectetur. Comedo voco vitae creo caelum vulpes corporis tempore.",
  "model_number": "183835",
  "tags": [],
  "requests": [
    {
      "request_id": 81,
      "user_id": 18,
      "status": "approved"
    },
    {
      "request_id": 73,
      "user_id": 4,
      "status": "outstanding"
    },
    {
      "request_id": 72,
      "user_id": 10,
      "status": "outstanding"
    },
    {
      "request_id": 71,
      "user_id": 1,
      "status": "outstanding"
    },
    {
      "request_id": 70,
      "user_id": 16,
      "status": "outstanding"
    },
    {
      "request_id": 64,
      "user_id": 10,
      "status": "outstanding"
    },
    {
      "request_id": 63,
      "user_id": 19,
      "status": "outstanding"
    },
    {
      "request_id": 57,
      "user_id": 5,
      "status": "outstanding"
    },
    {
      "request_id": 46,
      "user_id": 29,
      "status": "cancelled"
    },
    {
      "request_id": 40,
      "user_id": 24,
      "status": "outstanding"
    },
    {
      "request_id": 39,
      "user_id": 13,
      "status": "outstanding"
    }
  ],
  "custom_fields": [
    {
      "key": "modified_test_field_name",
      "value": null,
      "type": "short_text_type"
    },
    {
      "key": "location",
      "value": null,
      "type": "short_text_type"
    },
    {
      "key": "restock_info",
      "value": null,
      "type": "long_text_type"
    },
    {
      "key": "broken",
      "value": null,
      "type": "integer_type"
    },
    {
      "key": "# of times whatever",
      "value": null,
      "type": "integer_type"
    }
  ]
}
```

## ITEMS-5 Destroys custom fields associated with an item ##

### *PUT /api/items/{id}/clear_field_entries* ###

### Brief Description ###
Deletes either all custom field entries for an item, or a specified list of custom fields. If custom field names is empty, then all custom field associations are cleared.

Parameter  	  				| Description										| Data Type
------------- 				| -------------										| -------------
Authorization 				| Authorization Token **(Required)**				| Header/String
id						  	| Item ID **(Required)**							| Integer
custom_field_names	  		| List of custom field names *(Optional)*			| Comma Deliminated Strings

*Note:* Determining Item ID for an item can be obtained by using *GET /api/items*

### Response Messages ###
HTTP Status Code	| Reasons						
------------- 		| -------------											
200					| OK
401					| Unauthorized
404 				| Not Found
422					| Unprocessable Entity

### Sample Correct Input ###

![](http://i.imgur.com/mGX2VAI.png)

### Sample Outputs ###
**Successful Custom Field Clear (204)**
```javascript
no content
```

## ITEMS-6 Fill in custom field content for a particular item ##

### *PUT /api/items/{id}/update_field_entry* ###

### Brief Description ###
Updates custom field content for a custom field (found by custom field name) and item (found by item id) association.

Parameter  	  				| Description										| Data Type
------------- 				| -------------										| -------------
Authorization 				| Authorization Token **(Required)**				| Header/String
id						  	| Item ID **(Required)**							| Integer
custom_field_name  			| Custom Field to be Updated **(Required)**			| String
custom_field_content		| Custom Field Content **(Required)**				| Depends

*Note:* Determining Item ID for an item can be obtained by using *GET /api/items*

### Response Messages ###
HTTP Status Code	| Reasons						
------------- 		| -------------											
200					| OK
401					| Unauthorized
404 				| Not Found
422					| Unprocessable Entity

### Sample Correct Input ###

![](http://i.imgur.com/1z96w7U.png)

### Sample Outputs ###
**Successful Custom Field Update (204)**
```javascript
no content
```

## ITEMS-7 Import a bulk amount of items ##

### *POST /api/items/{id}/bulk_import* ###

### Brief Description ###
Adds a general number of items (including their tag associations and custom field associations).

Parameter  	  				| Description										| Data Type
------------- 				| -------------										| -------------
Authorization 				| Authorization Token **(Required)**				| Header/String
items_as_json				| Items JSON format **(Required)**					| JSON

### Response Messages ###
HTTP Status Code	| Reasons						
------------- 		| -------------											
204					| OK
404 				| Not Found
422					| Unprocessable Entity

### Sample Correct Input ###

![](http://i.imgur.com/donHYBh.png)

### Sample Outputs ###
**Successful Custom Field Update (204)**
```javascript
no content
```

## ITEMS-8 Finds all personal outstanding requests for a specific item ##

### *GET /api/items/{id}/self_outstanding_requests* ###

### Brief Description ###
Finds all personal outstanding requests for a specific item.

Parameter  	  				| Description										| Data Type
------------- 				| -------------										| -------------
Authorization 				| Authorization Token **(Required)**				| Header/String
id						  	| Item ID **(Required)**							| Integer

*Note:* Determining Item ID for an item can be obtained by using *GET /api/items*

### Response Messages ###
HTTP Status Code	| Reasons						
------------- 		| -------------											
200					| OK
401					| Unauthorized
404 				| Not Found
422					| Unprocessable Entity

### Sample Correct Input ###

![](http://i.imgur.com/sNqrzOO.png)

### Sample Outputs ###
**Successful Personal Outstanding Requests Fetch (200)**
```javascript
[]
```


## ITEMS-9 Finds all personal loans for a specific item ##

### *GET /api/items/{id}/self_loans* ###

### Brief Description ###
Finds all personal loans for a specific item.

Parameter  	  				| Description										| Data Type
------------- 				| -------------										| -------------
Authorization 				| Authorization Token **(Required)**				| Header/String
id						  	| Item ID **(Required)**							| Integer

*Note:* Determining Item ID for an item can be obtained by using *GET /api/items*

### Response Messages ###
HTTP Status Code	| Reasons						
------------- 		| -------------											
200					| OK
401					| Unauthorized
404 				| Not Found
422					| Unprocessable Entity

### Sample Correct Input ###

![](http://i.imgur.com/TsDKhPY.png)

### Sample Outputs ###
**Successful Personal Loans Fetch (200)**
```javascript
[
  {
    "id": 168,
    "request_id": 98,
    "item_id": 10,
    "item": "Electrical_Tape",
    "due_date": null,
    "quantity_on_loan": 3,
    "quantity_disbursed": 0,
    "quantity_returned": 0,
    "subrequest_type": "loan"
  }
]
```

## ITEMS-10 Item Search ##

### *GET /api/items* ###

### Brief Description ###
Search items based on query params

Parameter  	  				| Description									| Data Type
------------- 				| -------------									| -------------
Authorization 				| Authorization Token **(Required)**			| Header/String
search			  			| Fuzzy Item Search *(Optional)*				| String
model_search	  			| Strict Item Model Filter *(Optional)*			| String
required_tag_names			| Item Search for required tags *(Optional)*	| String
excluded_tag_names			| Item Filter out excluded tags *(Optional)*	| String

### Response Messages ###
HTTP Status Code	| Reasons						
------------- 		| -------------											
200					| OK
401					| Unauthorized
404 				| Not Found
422					| Unprocessable Entity

### Sample Correct Input ###

![](http://i.imgur.com/xzL8VYO.png)

### Sample Outputs ###
**Successful Item Search (200)**
```javascript
[
  {
    "name": "Resistor",
    "quantity": 9001,
    "description": "Cognomen ut tantillus consectetur. Comedo voco vitae creo caelum vulpes corporis tempore.",
    "model_number": "183835",
    "tags": [
      {
        "id": 1,
        "name": "ECE110",
        "created_at": "2017-03-27T18:12:05.934-04:00",
        "updated_at": "2017-03-27T18:12:05.934-04:00"
      }
    ]
  }
]
```

## ITEMS-11 Single Item Creation ##

### *POST /api/items* ###

### Brief Description ###
Creates single items based on input params

Parameter  	  		| Description								| Data Type
------------- 		| -------------								| -------------
Authorization 		| Authorization Token **(Required)**		| Header/String
item[unique_name]	| Item Name **(Required)**					| String
item[quantity]	  	| Item Starting Quantity **(Required)**		| Integer
item[description]	| Item Description *(Optional)*				| String
item[model_number]	| Item Model Number *(Optional)*			| String

### Response Messages ###
HTTP Status Code	| Reasons						
------------- 		| -------------											
200					| OK
401					| Unauthorized
404 				| Not Found
422					| Unprocessable Entity

### Sample Correct Input ###

![](http://i.imgur.com/ycJqr8h.png)

### Sample Outputs ###
**Successful Single Item Creation (200)**
```javascript
{
  "id": 28,
  "unique_name": "sample-item",
  "quantity": 3292,
  "description": "Sample Item for demonstration",
  "model_number": "492thk",
  "status": "active",
  "last_action": "created",
  "quantity_on_loan": 0
}
```


## ITEMS-12 Single Item Deletion ##

### *DELETE /api/items/{id}* ###

### Brief Description ###
Delete a single item based on its item ID.

Parameter  	  				| Description										| Data Type
------------- 				| -------------										| -------------
Authorization 				| Authorization Token **(Required)**				| Header/String
id						  	| Item ID **(Required)**							| Integer

*Note:* Determining Item ID for an item can be obtained by using *GET /api/items*

### Response Messages ###
HTTP Status Code	| Reasons						
------------- 		| -------------											
204					| OK
401					| Unauthorized
404 				| Not Found

### Sample Correct Input ###

![](http://i.imgur.com/QHPxZzl.png)

### Sample Outputs ###
**Successful Single Item Deletion (204)**
```javascript
no content
```

## ITEMS-13 Single Item Fetch ##

### *GET /api/items/{id}* ###

### Brief Description ###
Fetches a single item based on its item ID.

Parameter  	  				| Description										| Data Type
------------- 				| -------------										| -------------
Authorization 				| Authorization Token **(Required)**				| Header/String
id						  	| Item ID **(Required)**							| Integer

*Note:* Determining Item ID for an item can be obtained by using *GET /api/items*

### Response Messages ###
HTTP Status Code	| Reasons						
------------- 		| -------------											
200					| OK
401					| Unauthorized
404 				| Not Found
422					| Unprocessable Entity

### Sample Correct Input ###

![](http://i.imgur.com/4abSCrf.png)

### Sample Outputs ###
**Successful Single Item Show**
```javascript
{
  "name": "Resistor",
  "quantity": 9001,
  "description": "Cognomen ut tantillus consectetur. Comedo voco vitae creo caelum vulpes corporis tempore.",
  "model_number": "183835",
  "tags": [
    {
      "id": 1,
      "name": "ECE110",
      "created_at": "2017-03-27T18:12:05.934-04:00",
      "updated_at": "2017-03-27T18:12:05.934-04:00"
    }
  ],
  "requests": [
    {
      "request_id": 81,
      "user_id": 18,
      "status": "approved"
    },
    {
      "request_id": 73,
      "user_id": 4,
      "status": "outstanding"
    },
    {
      "request_id": 72,
      "user_id": 10,
      "status": "outstanding"
    },
    {
      "request_id": 71,
      "user_id": 1,
      "status": "outstanding"
    },
    {
      "request_id": 70,
      "user_id": 16,
      "status": "outstanding"
    },
    {
      "request_id": 64,
      "user_id": 10,
      "status": "outstanding"
    },
    {
      "request_id": 63,
      "user_id": 19,
      "status": "outstanding"
    },
    {
      "request_id": 57,
      "user_id": 5,
      "status": "outstanding"
    },
    {
      "request_id": 46,
      "user_id": 29,
      "status": "cancelled"
    },
    {
      "request_id": 40,
      "user_id": 24,
      "status": "outstanding"
    },
    {
      "request_id": 39,
      "user_id": 13,
      "status": "outstanding"
    }
  ],
  "custom_fields": [
    {
      "key": "modified_test_field_name",
      "value": null,
      "type": "short_text_type"
    },
    {
      "key": "restock_info",
      "value": null,
      "type": "long_text_type"
    },
    {
      "key": "broken",
      "value": null,
      "type": "integer_type"
    },
    {
      "key": "location",
      "value": "CIEMAS",
      "type": "short_text_type"
    },
    {
      "key": "# of times whatever",
      "value": null,
      "type": "integer_type"
    }
  ]
}
```

# Requests API #
----------

## ITEMS-1 Managers making decisions on requests ##

### *PUT/PATCH /api/requests/{id}/decision* ###

### Brief Description ###
Allows managers to make a decision on whether or not to approve a request.

### Sample Correct Input ###

![](http://i.imgur.com/1aAxYWp.png)

### Sample Outputs ###

```javascript
{
  "user": "exampleapproved-6@example.com",
  "reason": "Benigne molestiae traho architecto cursim ut. Nesciunt ustilo socius distinctio voluptas tenax ater adsidue.",
  "status": "approved",
  "requested_for": "tyrell konopelski",
  "request_type": "mixed",
  "sub_requests": [
    {
      "item": "Capacitor FOR A WHILE",
      "quantity_on_loan": 13,
      "quantity_disbursed": 21,
      "quantity_returned": 32,
      "subrequest_type": "mixed"
    },
    {
      "item": "Capacitor FOR A WHILE",
      "quantity_on_loan": 43,
      "quantity_disbursed": 13,
      "quantity_returned": 49,
      "subrequest_type": "mixed"
    },
    {
      "item": "RED_LED",
      "quantity_on_loan": 47,
      "quantity_disbursed": 15,
      "quantity_returned": 18,
      "subrequest_type": "mixed"
    }
  ]
}
```


## ITEMS-2 Create Subrequests for Existing Requests ##

### *POST /api/requests/{id}/create_req_items* ###

### Brief Description ###
Allows users to append to existing requests before a manager has made a decision whether to approve the request or not.

### Sample Correct Input ###

![](http://i.imgur.com/pHGQWhU.png)

### Sample Outputs ###

```javascript
{
  "user": "example-1@example.com",
  "reason": null,
  "status": "cart",
  "requested_for": "dr. rosina stark",
  "request_type": "mixed",
  "sub_requests": [
    {
      "item": "Resistor",
      "quantity_on_loan": 15,
      "quantity_disbursed": 13,
      "quantity_returned": 0,
      "subrequest_type": "mixed"
    },
    {
      "item": "Transistor",
      "quantity_on_loan": 0,
      "quantity_disbursed": 12,
      "quantity_returned": 0,
      "subrequest_type": "disbursement"
    }
  ]
}
```

## ITEMS-3 Destroy Subrequests for Existing Requests ##

### *DELETE /api/requests/{id}/destroy_req_items* ###

### Brief Description ###
Allows users to delete portions of a requests before a manager has made a decision whether to approve the request or not.

### Sample Correct Input ###

![](http://i.imgur.com/0uCAt2X.png)

### Sample Outputs ###

```javascript
{
  "user": "example-1@example.com",
  "reason": null,
  "status": "cart",
  "requested_for": "dr. rosina stark",
  "request_type": "indeterminate",
  "sub_requests": []
}
```

## ITEMS-4 Update Request Reason ##

### *PUT/PATCH /api/requests/{id}/update_general* ###

### Brief Description ###
Allows users to modify the reason for making a request while it is still outstanding.

### Sample Correct Input ###

![](http://i.imgur.com/CpaEGHU.png)


## ITEMS-5 Update Subrequests for Existing Requests ##

### *PUT/PATCH /api/requests/{id}/update_req_items* ###

### Brief Description ###
Allows users to modify subrequests from a request while it is still outstanding.

### Sample Correct Input ###

![](http://i.imgur.com/XIFLSna.png)

### Sample Outputs ###

```javascript
{
  "user": "adminusername@example.com",
  "reason": "Sample reason",
  "status": "approved",
  "requested_for": "admin",
  "request_type": "mixed",
  "sub_requests": [
    {
      "item": "Resistor",
      "quantity_on_loan": 25,
      "quantity_disbursed": 0,
      "quantity_returned": 0,
      "subrequest_type": "loan"
    },
    {
      "item": "Transistor",
      "quantity_on_loan": 35,
      "quantity_disbursed": 25,
      "quantity_returned": 0,
      "subrequest_type": "mixed"
    }
  ]
}
```

## ITEMS-6 Returning Loaned Items ##

### *PUT/PATCH /api/requests/{id}/return_req_items* ###

### Brief Description ###
Allows users to return items corresponding to a specific request.

### Sample Correct Input ###

![](http://i.imgur.com/nWMsz11.png)

### Sample Outputs ###

```javascript
{
  "user": "adminusername@example.com",
  "reason": "Sample reason",
  "status": "approved",
  "requested_for": "admin",
  "request_type": "mixed",
  "sub_requests": [
    {
      "item": "Transistor",
      "quantity_on_loan": 35,
      "quantity_disbursed": 25,
      "quantity_returned": 0,
      "subrequest_type": "mixed"
    },
    {
      "item": "Resistor",
      "quantity_on_loan": 1,
      "quantity_disbursed": 0,
      "quantity_returned": 24,
      "subrequest_type": "loan"
    }
  ]
}
```


## ITEMS-7 Shows Specific Subrequests ##

### *GET /api/requests/{id}/index_subrequests* ###

### Brief Description ###
Allows users to view subrequests and their details.

### Sample Correct Input ###

![](http://i.imgur.com/gG1hYmq.png)

### Sample Outputs ###

```javascript
[
  {
    "id": 155,
    "request_id": 84,
    "item_id": 1,
    "created_at": "2017-03-28T05:35:08.374-04:00",
    "updated_at": "2017-03-28T05:36:49.530-04:00",
    "quantity_loan": 1,
    "quantity_disburse": 0,
    "quantity_return": 24,
    "request_type": "disbursement",
    "due_date": null
  }
]
```


## ITEMS-8 Shows All Requests (or a subset for students) ##

### *GET /api/requests* ###

### Brief Description ###
Allows users to view requests

### Sample Correct Input ###

![](http://i.imgur.com/fsBF9FQ.png)

### Sample Outputs ###

```javascript
[
  {
    "id": 84,
    "user": "adminusername@example.com",
    "reason": "Sample reason",
    "status": "approved",
    "response": null,
    "request_initiator": 25,
    "request_type": "mixed",
    "sub_requests": [
      {
        "item": "Transistor",
        "quantity_on_loan": 35,
        "quantity_disbursed": 25,
        "quantity_returned": 0,
        "subrequest_type": "mixed"
      },
      {
        "item": "Resistor",
        "quantity_on_loan": 1,
        "quantity_disbursed": 0,
        "quantity_returned": 24,
        "subrequest_type": "loan"
      }
    ]
  },
  ...
]
```

## ITEMS-9 Creates new Requests ##

### *POST /api/requests* ###

### Brief Description ###
Placing requests

### Sample Correct Input ###

![](http://i.imgur.com/h9huF0r.png)

### Sample Outputs ###

```javascript
{
  "user": "adminusername@example.com",
  "reason": "Sample reason",
  "status": "approved",
  "requested_for": "admin",
  "request_type": "mixed",
  "sub_requests": [
    {
      "item": "Resistor",
      "quantity_on_loan": 25,
      "quantity_disbursed": 0,
      "quantity_returned": 0,
      "subrequest_type": "loan"
    },
    {
      "item": "Transistor",
      "quantity_on_loan": 35,
      "quantity_disbursed": 25,
      "quantity_returned": 0,
      "subrequest_type": "mixed"
    }
  ]
}
```

## ITEMS-10 Showing a Specific Request and its details ##

### *GET /api/requests/{id}* ### 

### Brief Description ###
Shows a specific request by ID.

### Sample Correct Input ###

![](http://i.imgur.com/fANtdnk.png)

### Sample Outputs ###

```javascript
{
  "user": "example-1@example.com",
  "reason": null,
  "status": "cart",
  "requested_for": "dr. rosina stark",
  "request_type": "indeterminate",
  "sub_requests": []
}
```


## ITEMS-11 - Bulk Minimum Stock
### *PUT/PATCH /api/items/{id}/bulk_minimum_stock* ###

### Brief Description ###
Allows a manager or admin to change the minimum stock of multiple items.

### Sample Correct Input ###

http://imgur.com/a/QU3Mx

### Sample Outputs ###

[
  {
    "id": 1,
    "unique_name": "Resistor",
    "quantity": 215,
    "description": "Cibo chirographum amita curtus ocer. Triginta arguo degero abscido.",
    "model_number": "dc11ee",
    "status": "active",
    "last_action": "backfill_requested",
    "quantity_on_loan": 400,
    "minimum_stock": 200,
    "has_stocks": false,
    "stock_threshold_tracked": true
  },
  {
    "id": 2,
    "unique_name": "Transistor",
    "quantity": 86,
    "description": "Vitium aufero defero. Astrum creta deludo vicissitudo similique eius torqueo timor.",
    "model_number": "05d093",
    "status": "active",
    "last_action": "backfill_request_satisfied",
    "quantity_on_loan": 900,
    "minimum_stock": 200,
    "has_stocks": false,
    "stock_threshold_tracked": true
  },
  {
    "id": 5,
    "unique_name": "Green_LED",
    "quantity": 589,
    "description": "Repellat aurum nam ut. Fugit vir thymbra cicuta amoveo.",
    "model_number": "d7ad64",
    "status": "active",
    "last_action": "acquired_or_destroyed_quantity",
    "quantity_on_loan": 0,
    "minimum_stock": 200,
    "has_stocks": true,
    "stock_threshold_tracked": false
  },
  {
    "id": 7,
    "unique_name": "Screw",
    "quantity": 7,
    "description": "Tempus dicta textor. Tamquam sit tam auctus curia iure.",
    "model_number": "0238a5",
    "status": "active",
    "last_action": "backfill_request_denied",
    "quantity_on_loan": 800,
    "minimum_stock": 200,
    "has_stocks": false,
    "stock_threshold_tracked": false
  }
]

## ITEMS-12 All Minimum Stock

### *PUT/PATCH /api/items/{id}/all_minimum_stock* ###

### Brief Description ###
Allows a manager or admin to change the minimum stock of all items.

### Sample Correct Input ###

http://imgur.com/a/EPywz

### Sample Outputs ###


```javascript

[
  {
    "id": 9,
    "unique_name": "BOE-Bot",
    "quantity": 2,
    "description": "Viriliter audacia depereo. Vivo odit subnecto catena.",
    "model_number": "ae53cc",
    "status": "active",
    "last_action": "loaned",
    "quantity_on_loan": 371,
    "minimum_stock": 60,
    "has_stocks": false,
    "stock_threshold_tracked": true
  },
  {
    "id": 13,
    "unique_name": "Server_Motor",
    "quantity": 908,
    "description": "Alioqui velit vulariter amiculum cavus. Videlicet tabgo adiuvo cupiditas civis.",
    "model_number": "66cd5b",
    "status": "active",
    "last_action": "created",
    "quantity_on_loan": 0,
    "minimum_stock": 60,
    "has_stocks": false,
    "stock_threshold_tracked": false
  },
  {
    "id": 15,
    "unique_name": "Seven_Segment_Display",
    "quantity": 378,
    "description": "Vulgus considero necessitatibus adficio cibus advenio deprimo. Quibusdam templum sufficio velut vitium cultellus.",
    "model_number": "ed3397",
    "status": "active",
    "last_action": "created",
    "quantity_on_loan": 0,
    "minimum_stock": 60,
    "has_stocks": false,
    "stock_threshold_tracked": false
  },
  {
    "id": 18,
    "unique_name": "jklj",
    "quantity": 23414,
    "description": "asdjkla",
    "model_number": "234",
    "status": "active",
    "last_action": "acquired_or_destroyed_quantity",
    "quantity_on_loan": 0,
    "minimum_stock": 60,
    "has_stocks": false,
    "stock_threshold_tracked": false
  },
  {
    "id": 17,
    "unique_name": "asdfaf",
    "quantity": 42,
    "description": "234234",
    "model_number": "23",
    "status": "active",
    "last_action": "backfill_requested",
    "quantity_on_loan": 1,
    "minimum_stock": 60,
    "has_stocks": false,
    "stock_threshold_tracked": true
  },
  {
    "id": 1,
    "unique_name": "Resistor",
    "quantity": 215,
    "description": "Cibo chirographum amita curtus ocer. Triginta arguo degero abscido.",
    "model_number": "dc11ee",
    "status": "active",
    "last_action": "backfill_requested",
    "quantity_on_loan": 400,
    "minimum_stock": 60,
    "has_stocks": false,
    "stock_threshold_tracked": true
  },
  {
    "id": 7,
    "unique_name": "Screw",
    "quantity": 7,
    "description": "Tempus dicta textor. Tamquam sit tam auctus curia iure.",
    "model_number": "0238a5",
    "status": "active",
    "last_action": "backfill_request_denied",
    "quantity_on_loan": 800,
    "minimum_stock": 60,
    "has_stocks": false,
    "stock_threshold_tracked": false
  },
  {
    "id": 16,
    "unique_name": "IC_Chip",
    "quantity": 207,
    "description": "Amicitia tergum odit abduco doloremque. Vomer tantillus vesco vergo.",
    "model_number": "6a6736",
    "status": "active",
    "last_action": "backfill_requested",
    "quantity_on_loan": 400,
    "minimum_stock": 60,
    "has_stocks": false,
    "stock_threshold_tracked": false
  },
  {
    "id": 14,
    "unique_name": "Piezo_Speaker",
    "quantity": 163,
    "description": "Explicabo amissio corrupti conicio copia avaritia atrox tego. Curia calco excepturi tactus totam sint crepusculum colo.",
    "model_number": "0d0186",
    "status": "active",
    "last_action": "backfill_requested",
    "quantity_on_loan": 50,
    "minimum_stock": 60,
    "has_stocks": false,
    "stock_threshold_tracked": true
  },
  {
    "id": 11,
    "unique_name": "Arduino_Kit",
    "quantity": 3,
    "description": "Denuncio vivo caritas depraedor adeptio ut. Cubicularis cur appono vomito.",
    "model_number": "73152d",
    "status": "active",
    "last_action": "backfill_request_approved",
    "quantity_on_loan": 492,
    "minimum_stock": 60,
    "has_stocks": true,
    "stock_threshold_tracked": true
  },
  {
    "id": 2,
    "unique_name": "Transistor",
    "quantity": 86,
    "description": "Vitium aufero defero. Astrum creta deludo vicissitudo similique eius torqueo timor.",
    "model_number": "05d093",
    "status": "active",
    "last_action": "backfill_request_satisfied",
    "quantity_on_loan": 900,
    "minimum_stock": 60,
    "has_stocks": false,
    "stock_threshold_tracked": true
  },
  {
    "id": 4,
    "unique_name": "RED_LED",
    "quantity": 234,
    "description": "Cervus bonus aeneus ipsam temporibus. Quasi caelum synagoga campana.",
    "model_number": "a30076",
    "status": "active",
    "last_action": "created",
    "quantity_on_loan": 0,
    "minimum_stock": 60,
    "has_stocks": false,
    "stock_threshold_tracked": false
  },
  {
    "id": 6,
    "unique_name": "Capacitor",
    "quantity": 490,
    "description": "Quis strenuus color libero accusamus. Patrocinor porro advenio in speculum curo quia.",
    "model_number": "628316",
    "status": "active",
    "last_action": "loaned",
    "quantity_on_loan": 89,
    "minimum_stock": 60,
    "has_stocks": true,
    "stock_threshold_tracked": true
  },
  {
    "id": 3,
    "unique_name": "Oscilloscope",
    "quantity": 290,
    "description": "Crustulum et sed usus. Rerum dedico nesciunt auctor aetas cohors eos repellendus.",
    "model_number": "200227",
    "status": "active",
    "last_action": "backfill_request_denied",
    "quantity_on_loan": 23,
    "minimum_stock": 60,
    "has_stocks": false,
    "stock_threshold_tracked": true
  },
  {
    "id": 8,
    "unique_name": "Washer",
    "quantity": 180,
    "description": "Confero vitiosus velut adsum accedo adultus. Deleo tutis victoria maiores via.",
    "model_number": "262869",
    "status": "active",
    "last_action": "created",
    "quantity_on_loan": 0,
    "minimum_stock": 60,
    "has_stocks": false,
    "stock_threshold_tracked": false
  },
  {
    "id": 5,
    "unique_name": "Green_LED",
    "quantity": 589,
    "description": "Repellat aurum nam ut. Fugit vir thymbra cicuta amoveo.",
    "model_number": "d7ad64",
    "status": "active",
    "last_action": "acquired_or_destroyed_quantity",
    "quantity_on_loan": 0,
    "minimum_stock": 60,
    "has_stocks": true,
    "stock_threshold_tracked": false
  },
  {
    "id": 19,
    "unique_name": "adfjadlfk",
    "quantity": 4,
    "description": "asdasdlkf",
    "model_number": "234",
    "status": "active",
    "last_action": "created",
    "quantity_on_loan": 0,
    "minimum_stock": 60,
    "has_stocks": false,
    "stock_threshold_tracked": false
  },
  {
    "id": 20,
    "unique_name": "adfasdfaw",
    "quantity": 234,
    "description": "",
    "model_number": "2134",
    "status": "active",
    "last_action": "created",
    "quantity_on_loan": 0,
    "minimum_stock": 60,
    "has_stocks": true,
    "stock_threshold_tracked": false
  },
  {
    "id": 12,
    "unique_name": "QTI_Sensor",
    "quantity": 1,
    "description": "Cohibeo cilicium subvenio averto vorax. Qui valde ex adultus commemoro dolorum viscus.",
    "model_number": "28ade2",
    "status": "active",
    "last_action": "acquired_or_destroyed_quantity",
    "quantity_on_loan": 0,
    "minimum_stock": 60,
    "has_stocks": false,
    "stock_threshold_tracked": true
  },
  {
    "id": 10,
    "unique_name": "Electrical_Tape",
    "quantity": 107,
    "description": "Paens ustilo arceo tabella ventosus. Labore deserunt solvo.",
    "model_number": "236a14",
    "status": "active",
    "last_action": "loaned",
    "quantity_on_loan": 13,
    "minimum_stock": 60,
    "has_stocks": false,
    "stock_threshold_tracked": true
  }
]

```

# Logs API #
----------
![](http://i.imgur.com/6zRyB8P.png)
![](http://i.imgur.com/hbHk5Iz.png)


# Settings API #
----------

## SETTINGS-1 Modifying Email Subject ##

### *PUT/PATCH /api/settings/{id}/modify_email_subject* ### 

### Brief Description ###
Modify subject line for loans reminder emails

### Sample Correct Input ###

![](http://i.imgur.com/Ypoi6K9.png)

### Sample Outputs ###

```javascript
{
  "email_subject": "Hello All!",
  "email_body": "Here is the prepended text that will edited",
  "email_dates": "03/31/17"
}
```


## SETTINGS-2 Modifying Email Body ##

### *PUT/PATCH /api/settings/{id}/modify_email_body* ### 

### Brief Description ###
Modify email body for loans reminder emails

### Sample Correct Input ###

![](http://i.imgur.com/WDASTl6.png)

### Sample Outputs ###

```javascript
{
  "email_body": "This is a sample email body.",
  "email_subject": "Hello All!",
  "email_dates": "03/31/17"
}
```


## SETTINGS-3 Modifying Email Dates ##

### *PUT/PATCH /api/settings/{id}/modify_email_dates* ### 

### Brief Description ###
Modify dates loans reminder emails are sent

### Sample Correct Input ###

![](http://i.imgur.com/Z9x2guZ.png)

### Sample Outputs ###

```javascript
{
  "email_body": "This is a sample email body.",
  "email_dates": "04/15/1995,06/07/1995",
  "email_subject": "Hello All!"
}
```

# Subscribers API #
----------
![](http://i.imgur.com/xYXG10h.png)

![](http://i.imgur.com/ZJ6fBtB.png)

![](http://i.imgur.com/o5Y5pqK.png)

# Backfills API #
----------

## BACKFILLS-1 Creating a Backfill ##

//// ### *POST /api/backfills/* ###

### Brief Description ###

Create a backfill for a given request_item. A user can only make a backfill for his/her own loan.

### Sample Correct Input ###

http://imgur.com/a/Aerkf

### Sample Outputs ###

```javascript
{
  "bf_status": "bf_request",
  "request_id": 108,
  "id": 187,
  "quantity_disburse": 1,
  "quantity_return": 0,
  "quantity_loan": 20,
  "item_id": 3,
  "created_at": "2017-04-17T22:51:37.799-04:00",
  "updated_at": "2017-04-17T23:04:02.696-04:00"
}
```


## BACKFILLS-2 Viewing All Backfills Made by a Certain User ##

////  ### *GET /api/backfills/* ###

### Brief Description ###
Allows API user to view all the backfill requests made by that user. If the API user is a manager or admin, he/she will see all the backfill requests made by all users.

### Sample Correct Input ###

http://imgur.com/a/iEKzM

### Sample Outputs ###

```javascript
[
  {
    "id": 159,
    "request_id": 88,
    "item_id": 2,
    "created_at": "2017-04-17T00:36:26.134-04:00",
    "updated_at": "2017-04-17T14:22:54.977-04:00",
    "quantity_loan": 900,
    "quantity_disburse": 0,
    "quantity_return": 0,
    "bf_status": "bf_satisfied"
  },
  {
    "id": 154,
    "request_id": 83,
    "item_id": 6,
    "created_at": "2017-04-17T00:29:08.195-04:00",
    "updated_at": "2017-04-17T14:05:54.143-04:00",
    "quantity_loan": 0,
    "quantity_disburse": 0,
    "quantity_return": 500,
    "bf_status": "bf_satisfied"
  },
  {
    "id": 14,
    "request_id": 36,
    "item_id": 16,
    "created_at": "2017-04-16T23:59:32.525-04:00",
    "updated_at": "2017-04-17T14:09:15.957-04:00",
    "quantity_loan": 12,
    "quantity_disburse": 30,
    "quantity_return": 0,
    "bf_status": "bf_satisfied"
  },
  {
    "id": 167,
    "request_id": 95,
    "item_id": 3,
    "created_at": "2017-04-17T15:32:23.925-04:00",
    "updated_at": "2017-04-17T15:33:06.567-04:00",
    "quantity_loan": 0,
    "quantity_disburse": 0,
    "quantity_return": 300,
    "bf_status": "bf_satisfied"
  },
  {
    "id": 158,
    "request_id": 87,
    "item_id": 17,
    "created_at": "2017-04-17T00:35:05.654-04:00",
    "updated_at": "2017-04-17T14:18:54.041-04:00",
    "quantity_loan": 1,
    "quantity_disburse": 0,
    "quantity_return": 0,
    "bf_status": "bf_satisfied"
  },
  {
    "id": 172,
    "request_id": 100,
    "item_id": 11,
    "created_at": "2017-04-17T16:03:35.898-04:00",
    "updated_at": "2017-04-17T16:15:50.476-04:00",
    "quantity_loan": 0,
    "quantity_disburse": 1,
    "quantity_return": 2,
    "bf_status": "bf_satisfied"
  },
  {
    "id": 168,
    "request_id": 96,
    "item_id": 14,
    "created_at": "2017-04-17T15:33:32.572-04:00",
    "updated_at": "2017-04-17T15:34:04.210-04:00",
    "quantity_loan": 0,
    "quantity_disburse": 0,
    "quantity_return": 200,
    "bf_status": "bf_satisfied"
  },
  {
    "id": 169,
    "request_id": 97,
    "item_id": 12,
    "created_at": "2017-04-17T15:34:18.931-04:00",
    "updated_at": "2017-04-17T15:35:10.025-04:00",
    "quantity_loan": 0,
    "quantity_disburse": 0,
    "quantity_return": 100,
    "bf_status": "bf_satisfied"
  },
  {
    "id": 164,
    "request_id": 92,
    "item_id": 11,
    "created_at": "2017-04-17T12:59:03.829-04:00",
    "updated_at": "2017-04-17T15:08:10.078-04:00",
    "quantity_loan": 0,
    "quantity_disburse": 1,
    "quantity_return": 1,
    "bf_status": "bf_satisfied"
  },
  {
    "id": 177,
    "request_id": 103,
    "item_id": 6,
    "created_at": "2017-04-17T16:24:20.871-04:00",
    "updated_at": "2017-04-17T16:25:31.130-04:00",
    "quantity_loan": 0,
    "quantity_disburse": 0,
    "quantity_return": 2,
    "bf_status": "bf_satisfied"
  },
  {
    "id": 166,
    "request_id": 93,
    "item_id": 16,
    "created_at": "2017-04-17T15:29:09.056-04:00",
    "updated_at": "2017-04-17T15:31:53.410-04:00",
    "quantity_loan": 0,
    "quantity_disburse": 1,
    "quantity_return": 200,
    "bf_status": "bf_satisfied"
  },
  {
    "id": 170,
    "request_id": 98,
    "item_id": 16,
    "created_at": "2017-04-17T15:35:54.072-04:00",
    "updated_at": "2017-04-17T15:36:17.541-04:00",
    "quantity_loan": 0,
    "quantity_disburse": 0,
    "quantity_return": 200,
    "bf_status": "bf_satisfied"
  },
  {
    "id": 171,
    "request_id": 99,
    "item_id": 6,
    "created_at": "2017-04-17T15:46:06.233-04:00",
    "updated_at": "2017-04-17T15:47:47.327-04:00",
    "quantity_loan": 0,
    "quantity_disburse": 1,
    "quantity_return": 300,
    "bf_status": "bf_satisfied"
  },
  {
    "id": 175,
    "request_id": 102,
    "item_id": 6,
    "created_at": "2017-04-17T16:22:16.506-04:00",
    "updated_at": "2017-04-17T16:23:34.667-04:00",
    "quantity_loan": 0,
    "quantity_disburse": 0,
    "quantity_return": 1,
    "bf_status": "bf_satisfied"
  },
  {
    "id": 187,
    "request_id": 109,
    "item_id": 14,
    "created_at": "2017-04-17T22:52:36.347-04:00",
    "updated_at": "2017-04-17T22:54:30.363-04:00",
    "quantity_loan": 50,
    "quantity_disburse": 21,
    "quantity_return": 0,
    "bf_status": "bf_request"
  },
  {
    "id": 184,
    "request_id": 108,
    "item_id": 3,
    "created_at": "2017-04-17T22:51:37.799-04:00",
    "updated_at": "2017-04-17T23:04:02.696-04:00",
    "quantity_loan": 20,
    "quantity_disburse": 1,
    "quantity_return": 0,
    "bf_status": "bf_request"
  }
]
```



## BACKFILLS-3 Create a Comment for a Backfill ##

### *PUT/PATCH /api/backfills/{id}/create_comment* ###

### Brief Description ###
Creates a comment for a given backfill. One must be a manager or admin to have this privilege.

### Sample Correct Input ###

http://imgur.com/a/znqPm

### Sample Outputs ###

```javascript
{
  "id": 84,
  "request_item_id": 115,
  "user_id": 28,
  "comment": "This backfill looks legitimate"
}
```


## BACKFILLS-4 Viewing All Comments for a Backfill ##

### *GET /api/backfills/{id}/view_comments* ###

### Brief Description ###
Shows all the comments made by all managers, for a given backfill

### Sample Correct Input ###

http://imgur.com/a/gdSyL

### Sample Outputs ###


```javascript
[
  {
    "id": 79,
    "request_item_id": 132,
    "user_id": 28,
    "comment": "this looks awesome!"
  },
  {
    "id": 80,
    "request_item_id": 132,
    "user_id": 28,
    "comment": "even better than I imagined! "
  },
  {
    "id": 81,
    "request_item_id": 132,
    "user_id": 28,
    "comment": "wonderful!"
  },
  {
    "id": 82,
    "request_item_id": 132,
    "user_id": 28,
    "comment": "a bit overrated replacement"
  },
  {
    "id": 83,
    "request_item_id": 132,
    "user_id": 28,
    "comment": "thank you so much!"
  },
]
```


## BACKFILLS-5 Change the Status of a Backfill ##

### *PUT/PATCH /api/backfills/{id}/change_status* ###

### Brief Description ###
Allows a manager or admin to change the status of a backfill.  

### Sample Correct Input ###

http://imgur.com/a/9n8oM

### Sample Outputs ###

```javascript

{
  "bf_status": "bf_denied",
  "id": 173,
  "quantity_disburse": 1,
  "quantity_return": 0,
  "quantity_loan": 20,
  "request_id": 108,
  "item_id": 3,
  "created_at": "2017-04-17T22:51:37.799-04:00",
  "updated_at": "2017-04-17T23:08:55.539-04:00"
}
```
