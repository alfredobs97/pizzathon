Quiero implementar una funcionalidad para que el usuario pueda compartir su perfil. El usuario por ahora se esta guardando en firestore,     
   quiero que haya un botón en su perfil que sea compartir perfil, cuando se pulsa en ese botón, debemos coger su display name, sanearlo        
   para quedarnos solo con un nombre y primer apellido y concatenar algun id, como el de su uid, al final para componer una url tal que         
   /p/nombre-apellido-uid. Esta url se guarda en Firestore por lo que luego podre recuperar el perfil del usuario buscando por ese campo.       
   Habra que crear una nueva ruta también para poder acceder a ese perfil