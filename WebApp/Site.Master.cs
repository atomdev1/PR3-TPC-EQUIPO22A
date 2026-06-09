using Dominio;
using Dominio.Enums;
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
        protected HyperLink lnkReservar;
        protected HyperLink lnkReservas;
        protected HyperLink lnkCupones;
        protected HyperLink lnkCalendario;
        protected System.Web.UI.WebControls.Label lblUsuario; 
        protected System.Web.UI.WebControls.LinkButton btnCerrarSesion;

        protected void Page_Load(object sender, EventArgs e)
        {
            if (Session["usuario"] == null)
            {
                Response.Redirect("~/Login.aspx");
                return;
            }

            if (!IsPostBack)
            {
                Usuario u = (Usuario)Session["usuario"];
                lblUsuario.Text = u.Nombre + " " + u.Apellido;
                MarcarSeccionActiva();
            }
        }

        protected void btnCerrarSesion_Click(object sender, EventArgs e)
        {
            Session.Abandon();
            Response.Redirect("~/Login.aspx");
        }

        // Resalta en el sidebar el link de la sección que se está viendo.
        private void MarcarSeccionActiva()
        {
            string pagina = Path.GetFileName(Request.AppRelativeCurrentExecutionFilePath);

            var links = new Dictionary<string, HyperLink>(StringComparer.OrdinalIgnoreCase)
            {
                { "Panel.aspx", lnkPanel },
                { "Canchas.aspx", lnkCanchas },
                { "CanchasCliente.aspx", lnkReservar },
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
