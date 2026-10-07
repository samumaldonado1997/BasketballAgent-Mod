#import <UIKit/UIKit.h>
#import <sqlite3.h>

@interface BAPassthroughWindow : UIWindow @end
@implementation BAPassthroughWindow
- (UIView *)hitTest:(CGPoint)p withEvent:(UIEvent *)e {
    UIView *h=[super hitTest:p withEvent:e];
    return h==self.rootViewController.view ? nil : h;
}
@end

@interface BACheatMenu : NSObject
@property(nonatomic,strong) UIWindow *window;
@property(nonatomic,strong) UIButton *bubble;
@property(nonatomic,strong) UIView *panel;
@property(nonatomic,strong) UIScrollView *scroll;
@end

@implementation BACheatMenu
+ (instancetype)shared { static BACheatMenu*x; static dispatch_once_t once; dispatch_once(&once,^{x=[BACheatMenu new];}); return x; }

- (void)start {
 dispatch_async(dispatch_get_main_queue(), ^{
  UIWindowScene *scene=nil;
  for(UIScene*s in UIApplication.sharedApplication.connectedScenes)
   if(s.activationState==UISceneActivationStateForegroundActive){scene=(UIWindowScene*)s;break;}
  if(!scene)return;
  self.window=(UIWindow*)[[BAPassthroughWindow alloc]initWithWindowScene:scene];
  self.window.windowLevel=UIWindowLevelAlert+5; self.window.backgroundColor=UIColor.clearColor;
  UIViewController*r=[UIViewController new]; r.view.backgroundColor=UIColor.clearColor;
  self.window.rootViewController=r; self.window.hidden=NO;
  self.bubble=[UIButton buttonWithType:UIButtonTypeSystem];
  self.bubble.frame=CGRectMake(16,155,58,58); self.bubble.layer.cornerRadius=29;
  self.bubble.backgroundColor=[UIColor colorWithWhite:.08 alpha:.94];
  [self.bubble setTitle:@"BA" forState:UIControlStateNormal];
  self.bubble.titleLabel.font=[UIFont boldSystemFontOfSize:18];
  [self.bubble addTarget:self action:@selector(toggle) forControlEvents:UIControlEventTouchUpInside];
  [r.view addSubview:self.bubble];
 });
}

- (NSString*)dbPath {
 NSArray*roots=@[
  NSSearchPathForDirectoriesInDomains(NSDocumentDirectory,NSUserDomainMask,YES).firstObject,
  NSSearchPathForDirectoriesInDomains(NSLibraryDirectory,NSUserDomainMask,YES).firstObject
 ];
 NSFileManager*fm=NSFileManager.defaultManager;
 for(NSString*r in roots){
  NSDirectoryEnumerator*en=[fm enumeratorAtPath:r];
  for(NSString*rel in en){
   NSString*p=[r stringByAppendingPathComponent:rel]; BOOL dir=NO;
   if(![fm fileExistsAtPath:p isDirectory:&dir]||dir)continue;
   sqlite3*db=NULL;
   if(sqlite3_open_v2(p.UTF8String,&db,SQLITE_OPEN_READONLY,NULL)==SQLITE_OK){
    sqlite3_stmt*st=NULL;
    BOOL ok=sqlite3_prepare_v2(db,"SELECT 1 FROM sqlite_master WHERE type='table' AND name='Players'",-1,&st,NULL)==SQLITE_OK && sqlite3_step(st)==SQLITE_ROW;
    if(st)sqlite3_finalize(st); sqlite3_close(db);
    if(ok)return p;
   } else if(db) sqlite3_close(db);
  }
 }
 return nil;
}

- (BOOL)hasColumn:(NSString*)col table:(NSString*)table db:(sqlite3*)db {
 NSString*q=[NSString stringWithFormat:@"PRAGMA table_info(%@)",table];
 sqlite3_stmt*st=NULL; BOOL found=NO;
 if(sqlite3_prepare_v2(db,q.UTF8String,-1,&st,NULL)==SQLITE_OK)
  while(sqlite3_step(st)==SQLITE_ROW){
   const unsigned char*n=sqlite3_column_text(st,1);
   if(n && [col caseInsensitiveCompare:[NSString stringWithUTF8String:(const char*)n]]==NSOrderedSame){found=YES;break;}
  }
 if(st)sqlite3_finalize(st); return found;
}

- (NSString*)run:(NSArray<NSString*>*)sql {
 NSString*p=[self dbPath]; if(!p)return @"No se encontró la base de datos de la partida.";
 sqlite3*db=NULL; if(sqlite3_open(p.UTF8String,&db)!=SQLITE_OK)return @"No se pudo abrir la base de datos.";
 int total=0; NSMutableArray*errors=[NSMutableArray array];
 sqlite3_exec(db,"BEGIN IMMEDIATE",NULL,NULL,NULL);
 for(NSString*q in sql){
  char*err=NULL;
  if(sqlite3_exec(db,q.UTF8String,NULL,NULL,&err)==SQLITE_OK) total+=sqlite3_changes(db);
  else { if(err){[errors addObject:[NSString stringWithUTF8String:err]];sqlite3_free(err);} }
 }
 if(errors.count) sqlite3_exec(db,"ROLLBACK",NULL,NULL,NULL); else sqlite3_exec(db,"COMMIT",NULL,NULL,NULL);
 sqlite3_close(db);
 return errors.count ? [NSString stringWithFormat:@"Sin cambios.\n%@",[errors componentsJoinedByString:@"\n"]] :
 [NSString stringWithFormat:@"Aplicado correctamente.\nFilas modificadas: %d",total];
}

- (void)toast:(NSString*)s {
 UIAlertController*a=[UIAlertController alertControllerWithTitle:@"Basketball Agent Cheat Menu" message:s preferredStyle:UIAlertControllerStyleAlert];
 [a addAction:[UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:nil]];
 [self.window.rootViewController presentViewController:a animated:YES completion:nil];
}
- (UIButton*)btn:(NSString*)t y:(CGFloat)y sel:(SEL)s {
 UIButton*b=[UIButton buttonWithType:UIButtonTypeSystem]; b.frame=CGRectMake(12,y,306,42);
 b.backgroundColor=[UIColor colorWithWhite:.16 alpha:1]; b.layer.cornerRadius=9;
 [b setTitle:t forState:UIControlStateNormal]; b.titleLabel.font=[UIFont systemFontOfSize:13 weight:UIFontWeightSemibold];
 [b addTarget:self action:s forControlEvents:UIControlEventTouchUpInside]; [self.scroll addSubview:b]; return b;
}
- (UILabel*)lab:(NSString*)t y:(CGFloat)y {
 UILabel*l=[[UILabel alloc]initWithFrame:CGRectMake(12,y,306,25)]; l.text=t;l.textColor=UIColor.whiteColor;
 l.font=[UIFont boldSystemFontOfSize:15]; [self.scroll addSubview:l]; return l;
}

- (void)toggle {
 if(self.panel){[self.panel removeFromSuperview];self.panel=nil;return;}
 self.panel=[[UIView alloc]initWithFrame:CGRectMake(20,75,334,650)];
 self.panel.backgroundColor=[UIColor colorWithWhite:.05 alpha:.98]; self.panel.layer.cornerRadius=18;
 [self.window.rootViewController.view addSubview:self.panel];
 UILabel*h=[[UILabel alloc]initWithFrame:CGRectMake(14,8,306,30)];h.text=@"Basketball Agent • Cheat Menu v3";h.textColor=UIColor.whiteColor;h.font=[UIFont boldSystemFontOfSize:17];[self.panel addSubview:h];
 self.scroll=[[UIScrollView alloc]initWithFrame:CGRectMake(2,42,330,600)]; self.scroll.contentSize=CGSizeMake(330,1370); [self.panel addSubview:self.scroll];
 CGFloat y=0;
 [self lab:@"AGENCIA" y:y]; y+=28;
 [self btn:@"💰 Dinero 999.999.999" y:y sel:@selector(money)]; y+=48;
 [self btn:@"🏆 Reputación máxima" y:y sel:@selector(rep)]; y+=58;
 [self lab:@"MIS REPRESENTADOS" y:y]; y+=28;
 [self btn:@"⭐ OVR + potencial 99" y:y sel:@selector(ovr)]; y+=48;
 [self btn:@"💎 Valor máximo" y:y sel:@selector(value)]; y+=48;
 [self btn:@"❤️ Relación agente/club máxima" y:y sel:@selector(rel)]; y+=48;
 [self btn:@"🔥 Forma máxima" y:y sel:@selector(form)]; y+=48;
 [self btn:@"🩹 Curar todas las lesiones" y:y sel:@selector(heal)]; y+=48;
 [self btn:@"♾️ Contratos largos + salario alto" y:y sel:@selector(contract)]; y+=58;
 [self lab:@"TRANSFERENCIAS" y:y]; y+=28;
 [self btn:@"🔓 Quitar bloqueos de transferencia" y:y sel:@selector(unlockTransfer)]; y+=48;
 [self btn:@"📋 Poner representados transferibles" y:y sel:@selector(transferable)]; y+=48;
 [self btn:@"🧹 Limpiar ofertas/listas" y:y sel:@selector(clearOffers)]; y+=58;
 [self lab:@"SCOUTING" y:y]; y+=28;
 [self btn:@"🔭 Activar toda la red" y:y sel:@selector(scoutActive)]; y+=48;
 [self btn:@"🔎 Scouting al 100%" y:y sel:@selector(scout100)]; y+=58;
 [self lab:@"CLUB CONTROLADO" y:y]; y+=28;
 [self btn:@"💵 Presupuesto del club máximo" y:y sel:@selector(clubMoney)]; y+=48;
 [self btn:@"🤝 Relación con club máxima" y:y sel:@selector(clubRelation)]; y+=48;
 [self btn:@"🏟️ Instalaciones al máximo" y:y sel:@selector(facilities)]; y+=58;
 [self lab:@"UTILIDADES" y:y]; y+=28;
 [self btn:@"⚡ GOD MODE representados" y:y sel:@selector(god)]; y+=48;
 [self btn:@"🧪 Diagnóstico de partida" y:y sel:@selector(diag)]; y+=48;
 [self btn:@"Cerrar menú" y:y sel:@selector(toggle)];
}

- (void)money {[self toast:[self run:@[@"UPDATE ajanslar SET money=999999999"]]];}
- (void)rep {[self toast:[self run:@[@"UPDATE ajanslar SET rep=9999"]]];}
- (void)ovr {[self toast:[self run:@[@"UPDATE Players SET ove=99,pa=99 WHERE sahip>0"]]];}
- (void)value {[self toast:[self run:@[@"UPDATE Players SET value=999999999 WHERE sahip>0"]]];}
- (void)rel {[self toast:[self run:@[@"UPDATE Players SET tem_sev=100,kulup_sev=100 WHERE sahip>0"]]];}
- (void)form {[self toast:[self run:@[@"UPDATE Players SET form=1.0 WHERE sahip>0"]]];}
- (void)heal {[self toast:[self run:@[@"UPDATE Players SET sakat=0 WHERE sahip>0"]]];}
- (void)contract {[self toast:[self run:@[@"UPDATE Players SET sez_bit=999,maas=99999999 WHERE sahip>0"]]];}
- (void)unlockTransfer {[self toast:[self run:@[@"UPDATE Players SET transfer_yasak=0,last_transfer=0 WHERE sahip>0"]]];}
- (void)transferable {[self toast:[self run:@[@"UPDATE Players SET gidebilir=1,liste=1 WHERE sahip>0"]]];}
- (void)clearOffers {[self toast:[self run:@[@"UPDATE Players SET oner=0,klist=0 WHERE sahip>0"]]];}
- (void)scoutActive {[self toast:[self run:@[@"UPDATE scout_network SET aktif=1"]]];}
- (void)scout100 {[self toast:[self run:@[@"UPDATE scout_network SET yuzde=100"]]];}
- (void)clubMoney {[self toast:[self run:@[@"UPDATE clubs SET butce=999999999 WHERE sahip>0"]]];}
- (void)clubRelation {[self toast:[self run:@[@"UPDATE clubs SET iliski=100 WHERE sahip>0"]]];}
- (void)facilities {[self toast:[self run:@[@"UPDATE clubs SET tesis=100,saglik=100,stad=100,market=100 WHERE sahip>0"]]];}
- (void)god {[self toast:[self run:@[
 @"UPDATE Players SET ove=99,pa=99,value=999999999,tem_sev=100,kulup_sev=100,form=1.0,sakat=0,transfer_yasak=0,last_transfer=0 WHERE sahip>0"
 ]]];}

- (void)diag {
 NSString*p=[self dbPath]; if(!p){[self toast:@"No se encontró la base de datos."];return;}
 sqlite3*db=NULL; if(sqlite3_open_v2(p.UTF8String,&db,SQLITE_OPEN_READONLY,NULL)!=SQLITE_OK){[self toast:@"No se pudo abrir la base de datos."];return;}
 NSArray*tables=@[@"Players",@"ajanslar",@"clubs",@"scout_network",@"sponsor"];
 NSMutableArray*out=[NSMutableArray arrayWithObject:[NSString stringWithFormat:@"DB: %@",p.lastPathComponent]];
 for(NSString*t in tables){
  sqlite3_stmt*st=NULL; NSString*q=[NSString stringWithFormat:@"SELECT COUNT(*) FROM %@",t];
  if(sqlite3_prepare_v2(db,q.UTF8String,-1,&st,NULL)==SQLITE_OK && sqlite3_step(st)==SQLITE_ROW)
   [out addObject:[NSString stringWithFormat:@"%@: %d",t,sqlite3_column_int(st,0)]];
  if(st)sqlite3_finalize(st);
 }
 sqlite3_close(db); [self toast:[out componentsJoinedByString:@"\n"]];
}
@end

__attribute__((constructor)) static void BAInit(void){
 dispatch_after(dispatch_time(DISPATCH_TIME_NOW,(int64_t)(2*NSEC_PER_SEC)),dispatch_get_main_queue(),^{[[BACheatMenu shared] start];});
}
