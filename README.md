# Grab It & Run!

פרויקט Roblox מקומי. מקור הקוד נמצא בתוך src; מסמכי ההגדרות בתוך docs/specs, ותוכניות המימוש בתוך docs/plans.

## מצב המשחק

נוצרה גרסה מקומית ראשונית. היא עדיין אינה עומדת בכל קריטריוני הקבלה. [דוח מימוש ובדיקות](docs/research/v1-implementation.md) מפרט מה הוכח ומה חסר.

## עבודה מקומית

עובדים במופע Studio אחד של קובץ המשחק הייעודי. משתמשים ב־default.project.json עבור Rojo, ומוודאים שהחלון הוא של הפרויקט הזה לפני סנכרון. אין לערוך קוד מסונכרן ישירות בתוך Studio.

הפקודות הבאות מיועדות להרצה משורש הפרויקט. קובץ ה־build הוא תוצר מקומי שמוחרג מתוך Git; קובצי המקור נשמרים.

```sh
rojo build default.project.json -o build/GrabItV1_DesktopMobile.rbxlx
rojo serve default.project.json --port 34872
```

את ה־tests מריצים דרך MCP במצב Edit של אותו פרויקט, מתוך ServerStorage.GrabItTests. tools/tests/run.luau הוא מקור ה־runner. אין צורך לפתוח מופע Studio חדש בכל סבב. test.project.json משמש לבנייה מבודדת כאשר נדרשת בדיקה כזאת, ולא כזרימת עבודה רגילה.

## שמירה ופרסום

במצב Studio השמירה בזיכרון השרת בלבד, עם הודעה מפורשת בממשק. לא אומתה שמירה בענן. לא הופעלו API Services ולא פורסם המשחק. רק אדם מבצע push.
