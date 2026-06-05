using System;
using System.Collections.Generic;
using System.IO;
using System.Web.UI.WebControls;

namespace WebApp
{
    public partial class Site : System.Web.UI.MasterPage
    {
        protected HyperLink lnkPanel;
        protected HyperLink lnkCanchas;
        protected HyperLink lnkReservas;
        protected HyperLink lnkCupones;
        protected HyperLink lnkCalendario;

        protected void Page_Load(object sender, EventArgs e)
        {
            MarcarSeccionActiva();
        }

        // Resalta en el sidebar el link de la sección que se está viendo.
        private void MarcarSeccionActiva()
        {
            string pagina = Path.GetFileName(Request.AppRelativeCurrentExecutionFilePath);

            var links = new Dictionary<string, HyperLink>(StringComparer.OrdinalIgnoreCase)
            {
                { "Panel.aspx", lnkPanel },
                { "Canchas.aspx", lnkCanchas },
                { "Reservas.aspx", lnkReservas },
                { "Cupones.aspx", lnkCupones },
                { "Calendario.aspx", lnkCalendario },
            };

            HyperLink activo;
            if (links.TryGetValue(pagina, out activo) && activo != null)
            {
                activo.CssClass += " active";
            }
        }
    }
}
