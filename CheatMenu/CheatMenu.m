#import <UIKit/UIKit.h>
#import <sqlite3.h>

@interface BACheatMenu : NSObject
@property(nonatomic,strong) UIWindow *window;
@property(nonatomic,strong) UIButton *bubble;
@property(nonatomic,strong) UIViewController *panel;
@end

@implementation BACheatMenu
+ (instancetype)shared { static BACheatMenu *x; static dispatch_once_t once; dispatch_once(&once, ^{ x=[BACheatMenu new]; }); return x; }
- (void)start {
 dispatch_async(dispatch_get_main_queue(), ^{
  UIWindowScene *scene=nil; for(UIScene *s in UIApplication.sharedApplication.connectedScenes) if(s.activationState==UISceneActivationStateForegroundActive){scene=(UIWindowScene*)s;break;}
  if(!scene) return;
  self.window=[[UIWindow alloc] initWithWindowScene:scene]; self.window.windowLevel=UIWindowLevelAlert+5; self.window.backgroundColor=UIColor.clearColor;
  UIViewController *root=[UIViewController new]; root.view.backgroundColor=UIColor.clearColor; self.window.rootViewController=root; self.window.hidden=NO;
  self.bubble=[UIButton buttonWithType:UIButtonTypeSystem]; self.bubble.frame=CGRectMake(18,160,58,58); self.bubble.layer.cornerRadius=29; self.bubble.backgroundColor=[UIColor colorWithWhite:.08 alpha:.92]; [self.bubble setTitle:@"BA" forState:UIControlStateNormal]; self.bubble.titleLabel.font=[UIFont boldSystemFontOfSize:18]; [self.bubble addTarget:self action:@selector(toggle) forControlEvents:UIControlEventTouchUpInside]; [root.view addSubview:self.bubble];
 });
}
- (UILabel*)label:(NSString*)t y:(CGFloat)y parent:(UIView*)v { UILabel*l=[[UILabel alloc]initWithFrame:CGRectMake(18,y,v.bounds.size.width-36,28)];l.text=t;l.textColor=UIColor.whiteColor;l.font=[UIFont boldSystemFontOfSize:16];[v addSubview:l];return l; }
- (UIButton*)button:(NSString*)t y:(CGFloat)y sel:(SEL)s parent:(UIView*)v { UIButton*b=[UIButton buttonWithType:UIButtonTypeSystem];b.frame=CGRectMake(18,y,v.bounds.size.width-36,42);b.backgroundColor=[UIColor colorWithWhite:.16 alpha:1];b.layer.cornerRadius=10;[b setTitle:t forState:UIControlStateNormal];[b addTarget:self action:s forControlEvents:UIControlEventTouchUpInside];[v addSubview:b];return b; }
- (void)toggle { if(self.panel){[self.panel.view removeFromSuperview];self.panel=nil;return;} UIViewController*p=[UIViewController new];p.view.frame=CGRectMake(22,90,330,590);p.view.backgroundColor=[UIColor colorWithWhite:.05 alpha:.97];p.view.layer.cornerRadius=18;self.panel=p;[self.window.rootViewController.view addSubview:p.view]; [self label:@"Basketball Agent Cheat Menu" y:16 parent:p.view]; [self label:@"v1.0 • BA 2.4.1 (363)" y:45 parent:p.view];
 [self label:@"AGENCIA" y:86 parent:p.view];[self button:@"💰 Establecer dinero: 999.999.999" y:116 sel:@selector(money) parent:p.view];
 [self label:@"JUGADORES" y:172 parent:p.view];[self button:@"⭐ Mis representados: Overall/Potencial 99" y:202 sel:@selector(players) parent:p.view];[self button:@"❤️ Relaciones y forma al máximo" y:250 sel:@selector(relations) parent:p.view];
 [self label:@"SCOUTING" y:306 parent:p.view];[self button:@"🔭 Maximizar red de scouting" y:336 sel:@selector(scout) parent:p.view];
 [self label:@"CLUB" y:392 parent:p.view];[self button:@"🏀 Mejorar club controlado" y:422 sel:@selector(club) parent:p.view];
 [self button:@"Cerrar menú" y:514 sel:@selector(toggle) parent:p.view]; }
- (NSString*)dbPath { // v1: discover the live save DB by schema instead of assuming a filename
 NSArray *roots=@[NSSearchPathForDirectoriesInDomains(NSDocumentDirectory,NSUserDomainMask,YES).firstObject,NSSearchPathForDirectoriesInDomains(NSLibraryDirectory,NSUserDomainMask,YES).firstObject]; NSFileManager*fm=NSFileManager.defaultManager;
 for(NSString*r in roots){NSDirectoryEnumerator*e=[fm enumeratorAtPath:r];for(NSString*rel in e){NSString*p=[r stringByAppendingPathComponent:rel];BOOL dir=NO;if(![fm fileExistsAtPath:p isDirectory:&dir]||dir)continue;sqlite3*db=NULL;if(sqlite3_open_v2(p.UTF8String,&db,SQLITE_OPEN_READONLY,NULL)==SQLITE_OK){sqlite3_stmt*st=NULL;int ok=sqlite3_prepare_v2(db,"SELECT 1 FROM sqlite_master WHERE type='table' AND name='Players'",-1,&st,NULL)==SQLITE_OK&&sqlite3_step(st)==SQLITE_ROW;if(st)sqlite3_finalize(st);sqlite3_close(db);if(ok)return p;}else if(db)sqlite3_close(db);}}
 return nil; }
- (BOOL)exec:(NSArray<NSString*>*)sql {NSString*p=[self dbPath];if(!p)return NO;sqlite3*db=NULL;if(sqlite3_open(p.UTF8String,&db)!=SQLITE_OK)return NO;BOOL ok=YES;for(NSString*q in sql){char*err=NULL;if(sqlite3_exec(db,q.UTF8String,NULL,NULL,&err)!=SQLITE_OK){ok=NO;if(err)sqlite3_free(err);break;}}sqlite3_close(db);return ok;}
- (void)toast:(NSString*)s {UIAlertController*a=[UIAlertController alertControllerWithTitle:@"Cheat Menu" message:s preferredStyle:UIAlertControllerStyleAlert];[a addAction:[UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:nil]];[self.window.rootViewController presentViewController:a animated:YES completion:nil];}
- (void)money {[self toast:[self exec:@[@"UPDATE ajanslar SET money=999999999"]]?@"Dinero modificado. Cambia de pantalla para refrescar.":@"No se pudo localizar/modificar la partida."];}
- (void)players {[self toast:[self exec:@[@"UPDATE Players SET ove=99, pa=99 WHERE owner IS NOT NULL AND owner<>0"]]?@"Jugadores representados mejorados.":@"La estructura de Players necesita ajuste en esta partida."];}
- (void)relations {[self toast:[self exec:@[@"UPDATE Players SET tem_sev=100, kulup_sev=100, form=100 WHERE owner IS NOT NULL AND owner<>0"]]?@"Relaciones y forma modificadas.":@"La estructura necesita ajuste."];}
- (void)scout {[self toast:[self exec:@[@"UPDATE scout_network SET level=100"]]?@"Scouting modificado.":@"La tabla usa otros campos; lo ajustaremos tras la prueba."];}
- (void)club {[self toast:@"Botón de diagnóstico activado. En la primera prueba no escribirá en clubs hasta identificar tu club activo con seguridad."];}
@end

__attribute__((constructor)) static void BAInit(void){ dispatch_after(dispatch_time(DISPATCH_TIME_NOW,(int64_t)(2*NSEC_PER_SEC)),dispatch_get_main_queue(),^{[[BACheatMenu shared] start];}); }
