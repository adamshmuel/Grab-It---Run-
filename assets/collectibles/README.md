# דגמי חפצים לבדיקה חזותית

שלושה דגמים מקומיים בפורמט של Roblox, לפי הכיוון החזותי שאדם אישר בתאריך 23/10/2026. המקור הוא קובצי model.json. קובצי project.json מאפשרים לייצר מכל אחד קובץ rbxmx שאפשר להשתמש בו בתוך Studio. לא נדרשת התקנה, רכישה או תמונה חיצונית.

| דגם | צורה | גודל שנבדק בתוך Studio | חלקים וצבעים |
| --- | --- | --- | --- |
| WoodCrate | ארגז קטן, לוחות, רצועות ופינות | רוחב 1.74, גובה 1.8, עומק 1.8 studs | 10 חלקים, 4 צבעים |
| ToolCase | מזוודה רחבה עם מכסה, ידית וסוגרים | רוחב 2.45, גובה 2.04, עומק 1.875 studs | 9 חלקים, 7 צבעים |
| EnergyCanister | מכל גלילי גבוה עם מכסה, טבעות וידית | רוחב 2.1, גובה 2.925, עומק 2.1 studs | 10 חלקים, 6 צבעים |

כל החלקים מקובעים ואינם מתנגשים. אין בדגמים scripts או הפניות לתוכן חיצוני. הדגמים משולבים באיסוף ובמטען דרך מודול Visuals. התבניות נשמרות ב־ServerStorage ואינן משוכפלות בפני עצמן לשחקנים. בניית הדגמים, העתקתם, הסתרתם האישית ונשיאה מעורבת נבדקו; בדיקת המראה המלאה עדיין בעבודה.

## שחזור הקבצים

מתוך תיקיית הפרויקט, שלוש הפקודות יוצרות את קובצי הדגמים בתוך build/prototypes:

```sh
mkdir -p build/prototypes
rojo build assets/collectibles/wood-crate.project.json -o build/prototypes/VisualPrototype_WoodCrate.rbxmx
rojo build assets/collectibles/tool-case.project.json -o build/prototypes/VisualPrototype_ToolCase.rbxmx
rojo build assets/collectibles/energy-canister.project.json -o build/prototypes/VisualPrototype_EnergyCanister.rbxmx
```

בדיקת הייצוא הראשונית: בתאריך 23/10/2026 הייצוא עבר באמצעות Rojo 7.7.1. בדיקת XML אישרה גדלים, צבעים, שמירת צורת Cylinder והיעדר scripts. התוצאות נשמרו בתוך docs/research/evidence/v1/native-visual-prototypes.json. אין עדיין צילום Studio, אישור חזותי או הוכחת ביצועים. אין להציג את הדגמים כאילו כבר עברו השוואה למתחרים.

לאחר סיום הצגת הדגמים אפשר למחוק את תוצרי rbxmx ולבנות אותם שוב מהמקור בעת הצורך. אין צורך ליצור או לשמור סביבות משחק נוספות עבורם.

בתאריך 24/10/2026 עברו שוב tests של המידות וההעתקה בתוך Studio וכן שלוש בניות הפרויקט. קובצי הייצוא הישנים הוסרו לאחר שילוב המקור במשחק. [תוצאות הבדיקה](../../docs/research/evidence/v1/visual-integration-check.json) מתעדות גם את חסימת הצילום; זו אינה קבלה חזותית.
