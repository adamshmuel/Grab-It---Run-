<div dir="rtl" lang="he">

# בדיקת חיבור והרצת tests

הקבצים כאן מיועדים רק למקום בדיקה זמני. אין כאן קוד של המשחק.

פרויקט <bdi dir="ltr" lang="en">Rojo</bdi> שבתיקייה מסנכרן רק את התיקייה <bdi dir="ltr">ReplicatedStorage.EnvironmentCheck</bdi>. אין לחבר אותו למקום עם עבודה חשובה.

במהלך <bdi dir="ltr" lang="en">playtest</bdi>, מריצים באמצעות <bdi dir="ltr" lang="en">Studio MCP</bdi> את הפונקציה שמוחזרת מהמודול <bdi dir="ltr">ReplicatedStorage.EnvironmentCheck.SmokeTest</bdi>. אפשר להריץ אותה בנפרד בצד <bdi dir="ltr" lang="en">Server</bdi> ובצד <bdi dir="ltr" lang="en">Client</bdi>.

הבדיקה משתמשת ב־<bdi dir="ltr" lang="en">assert</bdi> המובנה בשפה, ללא התקנת חבילה. היא בודקת שנתון מהקובץ המקומי הגיע למודול ב־Studio. ערך <bdi dir="ltr">revision = 1</bdi> חייב להכשיל אותה; ערך <bdi dir="ltr">revision = 2</bdi> חייב להעביר אותה, בלי לשנות את קובץ ה־test.

בין הרצות עוצרים ומתחילים <bdi dir="ltr" lang="en">playtest</bdi> מחדש כדי שלא להשתמש בתוצאת <bdi dir="ltr" lang="en">require</bdi> שנשמרה בזיכרון.

זו בדיקת תשתית בסיסית שאומתה בפועל. היא אינה מכסה את התנהגות המשחק. ה־tests של כל feature יתוכננו לפי ה־spec וה־plan שלו.

</div>
