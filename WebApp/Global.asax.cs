using System;
using System.IO;
using System.Web;

namespace WebApp
{
    public class Global : System.Web.HttpApplication
    {
        protected void Application_Start(object sender, EventArgs e)
        {
        }

        // Registra el error real antes de que customErrors muestre la pantalla de error al usuario.
        protected void Application_Error(object sender, EventArgs e)
        {
            Exception ex = Server.GetLastError();
            if (ex == null) return;

            // Los 404 no son crashes: no ensucian el log, los maneja customErrors.
            HttpException httpEx = ex as HttpException;
            if (httpEx != null && httpEx.GetHttpCode() == 404) return;

            try
            {
                string carpeta = Server.MapPath("~/App_Data");
                Directory.CreateDirectory(carpeta);

                string linea = string.Format("[{0:yyyy-MM-dd HH:mm:ss}] {1}{2}{3}{2}{2}",
                    DateTime.Now, Request != null ? Request.Url.ToString() : "(sin url)",
                    Environment.NewLine, ex);

                File.AppendAllText(Path.Combine(carpeta, "errores.log"), linea);
            }
            catch
            {
                // Si falla el log, no podemos hacer mucho mas: dejamos que customErrors siga.
            }
        }
    }
}