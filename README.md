# HomeworkPlanner

A simple open source homework planning system powered by Flutter.

With its origins back in a desktop app of the same name, this version of HomeworkPlanner provides a simple way to manage tasks and subjects in a way that is intuitive and practical: By providing a calendar view, you can drag any of your tasks to it and schedule not just the day in which they are due, but the exact date in which you will do them. And on the tasks view, you can write all of your tasks as you usually would in any tasking application, with support for separating tasks by subject and setting importance flags, among onther features.

Unlike modern task management applications that overload you with several features and details to add about your tasks, making catching up on your to-dos feel more like an accounting job of some kind, HomeworkPlanner is designed to be a simpler, cleaner option, focused primarily on what a student needs most: To know exactly how many tasks they need to do, which they are going to do today, and which they are leaving for another time. 

Key features include:

- Task system with the following task attributes: Name, subject, description, due date, exec date, description (for adding details), importance (which is boolean, either it is or not), and completion (is it or not completed, and which day was it). This is all that is stored about any single task.
- Subject system, with support for setting colors to subjects.
- Schedule system, such that you are able to program in your current class timetables, and instead of remembering them on your head when a task is "for the next class", HomeworkPlanner calculates when the next class will be, preventing "oops, forgot there was this class today" moments.
- Day notes system, such that you can add notes to any specific day to remind yourself in the future about events that may occur, and if you feel like it or need it, cancel days out entirely such that no tasks can be scheduled to them.
- Report view, such that if you are feeling statistic, you can get details on when each task was done (thanks to the fact that task completion date is saved)
- Customizable calendar view, which allows you to set what days of the week you are studying in and how many weeks ahead do you want to plan for.
- Multiplatform, as it's Flutter based
- Open source, so you can inspect the code and contribute if you feel like it

This system was programmed in hope that it might be useful. It was made possible by several open-source packages whose licenses are included in the program's about screen. See them for any info on copyright related to the components which this project references.
