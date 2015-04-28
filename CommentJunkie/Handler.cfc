<!---

	Copyright 2009, Code Craftings
 
Licensed under the Apache License, Version 2.0 (the "License"); 
you may not use this file except in compliance with the License.
You may obtain a copy of the License at 
	
	http://www.apache.org/licenses/LICENSE-2.0 
	
Unless required by applicable law or agreed to in writing, software 
distributed under the License is distributed on an "AS IS" BASIS, 
WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied. 
See the License for the specific language governing permissions and 
limitations under the License.

--->
<cfcomponent displayname="Handler" extends="BasePlugin">
	
	<cfset variables.name = "CommentJunkie" />
	<cfset variables.id = "com.codecraftings.plugins.CommentJunkie" />
	<cfset variables.package = "com/codecraftings/plugins/CommentJunkie" />

<!--- :::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::: --->	
	<cffunction name="init" access="public" output="false" returntype="any">
		<cfargument name="mainManager" type="any" required="true" />
		<cfargument name="preferences" type="any" required="true" />
		
			<cfset var blogID = arguments.mainManager.getBlog().getId() />
			<cfset variables.manager = arguments.mainManager />
			<cfset variables.daoPath = replaceNoCase(getMetaData(this).name,"user.CommentJunkie.Handler","system.SubscriptionHandler.SubscriptionDAO") />
		
		<cfreturn this/>
	</cffunction>

<!--- :::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::: --->	
	<cffunction name="getName" access="public" output="false" returntype="string">
		<cfreturn variables.name />
	</cffunction>

<!--- :::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::: --->	
	<cffunction name="setName" access="public" output="false" returntype="void">
		<cfargument name="name" type="string" required="true" />
		<cfset variables.name = arguments.name />
		<cfreturn />
	</cffunction>

<!--- :::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::: --->	
	<cffunction name="getId" access="public" output="false" returntype="any">
		<cfreturn variables.id />
	</cffunction>
	
<!--- :::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::: --->	
	<cffunction name="setId" access="public" output="false" returntype="void">
		<cfargument name="id" type="any" required="true" />
		<cfset variables.id = arguments.id />
		<cfreturn />
	</cffunction>

<!--- :::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::: --->	
	<cffunction name="setup" hint="This is run when a plugin is activated" access="public" output="false" returntype="any">
		<cfset var msg = "The Comment Junkie plugin activated!" />
		
		<cfreturn msg />
	</cffunction>
	
<!--- :::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::: --->	
	<cffunction name="unsetup" hint="This is run when a plugin is de-activated" access="public" output="false" returntype="any">
		<cfreturn />
	</cffunction>

<!--- :::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::: --->	
	<cffunction name="handleEvent" hint="Asynchronous event handling" access="public" output="false" returntype="any">
		<cfargument name="event" type="any" required="true" />	

		<cfset var authors = "" />
		<cfset var subscribeUs = false />
		<cfset var queryInterface = variables.manager.getQueryInterface() />
		<cfset var dao = createObject("component","#variables.daoPath#").init(queryInterface) />
		<cfset var x = "" />
		<cfset var postID = "" />
		<cfset var eventName = arguments.event.name />
		<cfset var authorGateway = "">
		
		<!--- New posting --->
		<cfif eventName eq "afterPostAdd">
			<cfset post = arguments.event.getNewItem() />
							
			<!--- Only subscribe if the posting is "published" --->
			<cfif compareNoCase(post.getStatus(),"published") eq 0>
				<cfset subscribeUs = true />
			</cfif>
		</cfif>
		
		<!--- Posting has been updated --->
		<cfif eventName eq "afterPostUpdate">
			<cfset post = arguments.event.getNewItem() />
			<cfset oldPost = arguments.event.getOldItem() />
			
			<!--- Only subscribe if status changed from "draft" to "published" --->
			<cfif compareNoCase(post.getStatus(),"published") eq 0 AND compareNoCase(oldPost.getStatus(),"draft") eq 0>
				<cfset subscribeUs = true />
			</cfif>
		</cfif>
		
		<cfif subscribeUs>
			<cfset authorGateway = variables.manager.getAuthorsManager() />
			<cfset authors = authorGateway.getAuthors() />
			<cfset postID = post.getID() />
			<cfset poster = post.getAuthorID() />
			<!--- Create the subscriptions --->
			<cfloop from="1" to="#arraylen(authors)#" index="x">
				<cfif authors[x].getID() neq poster>
					<cfset dao.create(postID,authors[x].getEmail(),authors[x].getName(),"comments","instant") />				
				</cfif>
			</cfloop>
		</cfif>

		<cfreturn />
	</cffunction>

<!--- :::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::: --->	
	<cffunction name="processEvent" hint="Synchronous event handling" access="public" output="false" returntype="any">
		<cfargument name="event" type="any" required="true" />

		<cfreturn />
	</cffunction>
	
</cfcomponent>