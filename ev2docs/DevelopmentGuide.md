# Development Guide

Our software, the Spicy Software ECE Inventory System, is a web application built using the Ruby on Rails framework.

One key feature of the Ruby on Rails stack is that it favors convention over configuration, meaning that it provides users with default structures for a database and the web pages themselves, based on the Model-View-Controller (MVC) framework.

The database used by Spicy Software Inc. is PostSQL, but main database operations are performed by ActiveRecord, which provides default database operations without having the user to interact with the database directly.

The ECE Inventory system is composed of several interacting model classes, listed in the table below.


The database consists of tables with the model classes as the primary (lookup) key. The fields of these tables include all the fields of the model classes. Table 1 below displays each model class along with its attributes, such that there is a table for each model class. For instance, the fields of the item class include the unique name, model number, quantity, location, and the description of the item. 

| Model Class |                                                       Fields                                                       |
|-------------|:------------------------------------------------------------------------------------------------------------------:|
| User        | username, password_digest, email, created_at, updated_at, status, privilege, auth_token |
| Item        | unique_name, quantity, model_number, description, location, status, last_action                                                         |
| Custom_Field | field_name, private_indicator, field_type | 
| Item_Custom_Field | item_id, custom_field_id, short_text_content, long_text_content, integer_content, float_content|
| Tag         | name                                                                                    |
| Item_Tag   | tag_id, item_id                                                                            |
|Request     | reason, created_at, updated_at, status, response, user_id   |
| Request_Item | request_id, item_id, created_at, updated_at, quantity|
| Log        | created_at, user_id, log_type|
| Item_Log | log_id, item_id, action, curr_quantity, quantity_change, old_name, new_name, old_desc, new_desc, old_model_num, new_model_num, |
| User_Log | log_id, user_id, action, old_privilege, new_privilege |
| Request_Log | log_id, request_id, action |
| Stack_Exchange | created_at, updated_at |

The User, Item, Custom_Field, Tag, Request, and Log refer to items explicitly mentioned in the requirements. The additional fields are to improve and enhance associations and navigation between the classes. They will all be discussed in detail below.

In many cases, a table contains a field that is already a model class. For instance, the Request table contains the fields item_id and user_id. In these cases, a foreign key relation is established to speed-up the lookup of an item in the request table.  

Below we will briefly describe the use of each case in our project and describe their fields.

### Users

A user instance is created for every user in the system, whether their accounts are locally created by admin or linked with a NetID Oauth account. 

##### FIELDS
* **username** - This field must be unique, and is the name displayed with the user on the UI. It is specified by the administrator or it is the NetID of the student. 
* **password_digest** - This is the salted and hashed version of each user's password.
* **created_at**/**updated_at** - These are fields created and maintained by the system, and can be used in logging that note the most recent time the user was created or updated, respectively.
* **email** - Emails are required to be unique. In Evolution 1, we used the email in order to confirm user accounts. This evolution, this functionality has been stripped in favor of the OAuth extensions, but we maintain this record because we foresee that future functionalities may be enhanced by email capabilities. We do require that emails have the *@duke.edu* extension.
* **privilege** - There are three possible enums for privilege: student, manager, and admin. Privileges determine the level of access the users have in the system. Privileges are nested, and will be discussed in more detail later in this guide.
* **status** - By default, users are "approved" when their accounts are created. If at any time in the future, admins or managers desire to deactivate users, that functionality is available. Deactivated users will not be able to login to their accounts at all, and therefore cannot access the system; nevertheless, their records will persist.
* **auth_token** - 

##### ASSOCIATIONS
* has-many REQUESTS
* has-many USER_LOGS

### Items
Each item instance represents a type of equipment in the inventory system. Items can be created and edited by managers or administrators. 
##### FIELDS
* **unique_name** - This is the name given to an item. As the name suggests, it must be unique. This is the name displayed in the UI for readability.
* **quantity** - This field notes the quantity of the item that is currently in the inventory. This must be an integer.
* **model_number**/**description** - These two fields enhance and provide a further description of each item beyond its name. 
* **location** - This field informs a user of the current location of the item in question.
* **status** - An item can either be active or deactive. A deactive item cannot be requested, disbursed, etc. However, its logged record is maintained and is viewable by administrators. An active item can be subject to all the requirements of this inventory system.
* **last_action** - This field was provided to provide information when logging quantity changes. In this way, quantity can be updated in both the items and requests controller (when an item is in a request that is approved, the quantity in the inventory is updated), but logging can stay automatic within the model. 

##### ASSOCIATIONS
* has-many TAGS, through ITEM_TAGS
* has-many ITEM_TAGS
* has-many REQUESTS, through REQUEST_ITEMS
* has-many REQUEST_ITEMS
* has-many CUSTOM_FIELDS, through ITEM_CUSTOM_FIELDS
* has-many ITEM_CUSTOM_FIELDS

### Tags
Tags help classify items, and are created by administrators. Items are searchable via their tags. 
##### FIELDS
* **name** - This is the unique name that identifies a tag and will be what users use to search for relevant equipment. 

##### ASSOCIATIONS
* has-many ITEMS, through ITEM_TAGS
* has-many ITEM_TAGS

### Item_Tags
Item tags exist to keep track of the many relationships between various items and tags, as there exists a many-to-many relationship between the two items. 

##### FIELDS
* **item_id/tag_id** - Keeps track of the specific item and tag which are associated.

##### ASSOCIATIONS
* belongs-to ITEMS
* belongs-to TAGS

### Custom_Fields
##### FIELDS
* **field_name** - 
* **private_indicator** -
* **field_type** -

##### ASSOCIATIONS
* has-many ITEMS through ITEM_CUSTOM_FIELDS
* has-many ITEM_CUSTOM_FIELDS

### Item_Custom_Fields
##### FIELDS
* **item_id** -
* **custom_field_id** -
* **short_text_content** -
* **long_text_content** -
* **integer_content** -
* **float_content** - 

##### ASSOCIATIONS
* belongs-to CUSTOM_FIELDS
* belongs-to ITEMS

### Requests
Requests are the means through which item disbursements are handled. All users have access to an initial request, referred to as a cart, to which they can add items and corresponding quantities at will. Requests can then be submitted for approval via students or for direct logging of disbursements via managers or administrators. 

##### FIELDS
* **user_id** - This keeps track of the user to whom the request disbursement is going. The administrator or manager who files a request on behalf of another user is not noted directly with the quest, but is noted in the corresponding log entry which is generated.
* **created_at**/**updated_at** - Gives the time of creation and updating respectively for requests.
* **status** - Requests have four enum options for requests. At the very beginning, they are "cart"s; every user can only be associated with a single cart. After carts are submitted for approval, they become "outstanding" while they wait for administrative response. If an admin or manager directly submits their cart, or if they approve outstanding requests, those requests become "approved"; admin and managers can also classify requests as "denied".
* **reason** - Users must supply a reason before they are allowed to submit a request. This text area is mandatory. 
* **response** - Administrators are allowed to add a response to a request if they choose to approve or deny an outstanding request.

##### ASSOCIATIONS
* has-many ITEMS, through REQUEST_ITEMS
* has-many REQUEST_ITEMS
* belongs-to USERS

### Request_Items
Request_Items exist for each instance of an item within a request. This object also keeps track of the quantity of the specific item in the specific request.
request_id, item_id, created_at, updated_at, quantity|
##### FIELDS
* **request_id** - This is the id of the request with which the request_item is associated.
* **item_id** - This is the id of the item with which the request_item is associated.
* **quantity** - This field specifies the quantity of the item included on the specific request.
* **created_at**/**updated_at** - These fields keep track of the date and time at which the request_item is created and updated.

##### ASSOCIATIONS
* belongs-to REQUESTS
* belongs-to ITEMS

### Logs
This is the overall log table which includes entries for every action taken in the system related to user, item, and request workflow. Logs are automatically generated in the models of each of these classes upon creation and update, and cannot be modified by any user. 

##### FIELDS
* **created_at** - This field reports when logs were created, and is an additional field by which users can search logs.
* **user_id** - This field specifies the user who did the initiating action which caused the corresponding log entry. 
* **log_type** - This is an enum which specifies which object was directly edited to generate this log. Because we do not want to include extraneous columns within the log table in order to accommodate the different classes, this will allow us to query the sub-log tables (item_logs, user_logs, and request_logs) in order to grab the details of each log. The enums for this are "request", "user", and "item".

This object has no associations, due to its split nature.

### Item_Logs
Item_Logs keeps the specific information related to every transaction that has to do with item creation, deletion, or field change.

##### FIELDS
* **log_id** - This references the entry in the log table which this item_log belongs to. In this way, we can query the Item_Logs in order to find the specific information for any entry in the log table whose log_type is "item".
* **item_id** - This field references the exact item affected by this log.
* **action** - This specifies the exact change that the item underwent. Item actions have 6 enum options: they can be created, deleted, acquired or destroyed, corrected by the administrator (quantity specifically), or had their name/description/model_number updated. This allows us to know what to show in the view.
* **curr_quality**/**quantity_change** - These fields reflect the new quantity value of the item and the quality change from the previous value respectively. These values will be accessed if an item is destroyed/lost/disbursed (quantity_change is negative) or acquired (quantity_change is positive), or if an administrator makes a quantity correction.
* **old_name**/**new_name** - These field will be checked if the action reported is a description update; they track the names of the item before and after the change.
* **old_desc**/**new_desc** - These field will be checked if the action reported is a description update; they track the descriptions of the item before and after the change.
* **old_model_num**/**new_model_num** - These field will be checked if the action reported is a description update; they track the model numbers of the item before and after the change.

### User_Logs
User_Logs keeps track of the details of every transaction that has to do with user creation, deletion, or privilege change.

##### FIELDS
* **log_id** - This references the entry in the log table which this user_log belongs to. In this way, we can query the User_Logs in order to find the specific information for any entry in the log table whose log_type is "user".
* **user_id** - This references the specific user whose creation/deletion/privilege-change has caused this automatic logging.
* **action** - This specifies the exact change that the user underwent. User actions have 3 enum options: they can be created, deleted, or have their privilege changed.
* **old_privilege**/**new_privilege** - These field will be checked if the action reported is a privilege change; they track the privileges of the user before and after the change.

### Request_Logs
Request_Logs keep track of the details of every transaction that has to do with a request status change, from cart to outstanding, cancelled, approved, and/or denied.
log_id, request_id, action
##### FIELDS
* **log_id** - This references the entry in the log table which this request_log belongs to. In this way, we can query the Request_Logs in order to find the specific information for any entry in the log table whose log_type is "request".
* **request_id** - This references the specific request whose status change has caused this automatic logging.
* **action** - This specifies the exact change that the request underwent. Request actions have 4 options: they can be "placed" (when the carts are submitted), approved, denied, or cancelled.

### Stack Exchanges
Stack Exchanges is a class provided by OAuth in order to allow for NetID login functionality. We do not touch Stack Exchanges.

 
## Deployment

Please refer to the our [deployment guide](DeploymentGuide.md). 

## Within System Rules
### Privileges
