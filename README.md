# HomeworkPlanner
*Homework planning system based on C# (.NET) Windows Forms*

Tired of using task systems that don't allow you to **plan** when exactly you are getting something done? Fixing that issue is the mission of HomeworkPlanner, a simple open source tool made using .NET which aims to make managing tasks easier by providing an interface for the user to both set when tasks are due and also schedule the day they will be done.

# About

One of the issues with homework management is just the fact that -- when tough times come -- you don't yet have an easy platform that allows visualizing all of your homeworks or tasks, and define exactly the day when they will be done. You might use calendar systems, but they weren't made **specifically** for tasks or homeworks, which leaves aside features such as subject management and importance.
Due to this, some (like me) may even resort to using good old pen and paper to set up a schedule. And when doing so for high school work I found that setting up a system like this one (by setting aside all my tasks in one panel, with details and everything, and creating a plan on the other, that sets when exactly each task will be done) made viewing and understanding all the tasks I had a whole lot easier. 
Bringing a kind of system like that to a computer screen is what HomeworkPlanner is about. Although a very simple app, it allows you to manage and schedule homeworks much more easily by taking advantage of modern larger-size displays.
This program is also free software, meaning you are free to take a look at the source code for it, improve it, or create your own version of it. Contributions are welcome!

# Basic usage

* When you start up HomeworkPlanner, you will be met with the Welcome screen. From there you can open any recent plans you might have created or start a new one from scratch.
* The interface consists of a top menu, from where you can access the program's options, a status bar, which displays information regarding the current day's tasks, a calendar-style panel in the left, to which you can drag tasks to schedule them, and a smaller panel to the right, which displays all your tasks and their details
* To create a task, click the "Create new task" button or go to *Tasks > New...*. From there you can add info such as the task name, due date, subject, details, and whether or not it is important. Task icons will change depending on what you have provided
* To manage subjects, you can either select the "Edit subjects" option when selecting a task's subject, or go to *Tools > Subjects*. From there you may create a custom list of subjects to categorize each task.
* From the *View* menu, you may also customize how many weeks to display or which days of the week to display in the left-hand panel.
* In order to cancel a day out, which means to set a day aside for not doing any homeworks in advance, you can go to *Tools > Day cancelling*
* If any issue arises, you can try cleaning up your save file by going to *Tools > Cleanup...*
* By default, the program hides tasks completed prior to today, in order to display only the relevant tasks. If you wish, you may disable that by going to *View > Display previous tasks*
