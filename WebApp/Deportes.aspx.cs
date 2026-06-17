using System;
using System.Collections.Generic;
using Dominio;
using Dominio.Enums;
using Negocio;

namespace WebApp
{
    public partial class Deportes : System.Web.UI.Page
    {
        protected void Page_Load(object sender, EventArgs e)
        {
            Usuario u = Session["usuario"] as Usuario;
            if (u == null) { Response.Redirect("~/Login.aspx"); return; }
            if (u.Rol == RolUsuario.Cliente) { Response.Redirect("~/Dashboard.aspx"); return; }

            if (!IsPostBack)
                CargarDeportes();
        }

        private void CargarDeportes()
        {
            NegocioDeportes nDeportes = new NegocioDeportes();
            List<Deporte> deportes = nDeportes.ObtenerTodas();

            rptDeportes.DataSource = deportes;
            rptDeportes.DataBind();

            lblTotal.Text = deportes.Count == 1
                ? "1 deporte registrado"
                : deportes.Count + " deportes registrados";
        }

        protected void rptDeportes_ItemCommand(object source, System.Web.UI.WebControls.RepeaterCommandEventArgs e)
        {
            int idDeporte = int.Parse(e.CommandArgument.ToString());

            if (e.CommandName == "Editar")
            {
                Deporte d = new NegocioDeportes().ObtenerPorId(idDeporte);
                if (d == null) return;

                hfIdDeporte.Value = d.IdDeporte.ToString();
                txtNombre.Text    = d.Nombre;
                txtDuracion.Text  = d.DuracionMinutos.ToString();

                lblTituloModalDeporte.Text = "Editar deporte";
                lblErrorDeporte.Visible = false;
                AbrirModal();
            }
            else if (e.CommandName == "Baja")
            {
                // No se da de baja directo: se pide confirmación con un panel.
                Deporte d = new NegocioDeportes().ObtenerPorId(idDeporte);
                hfBajaId.Value = idDeporte.ToString();
                string nombre = d != null ? d.Nombre : "";

                // Si hay canchas activas usando el deporte, avisamos antes de confirmar.
                int canchasActivas = new NegocioCanchas().ContarCanchasActivasPorDeporte(idDeporte);
                if (canchasActivas > 0)
                {
                    string sustantivo = canchasActivas == 1 ? "cancha activa asociada" : "canchas activas asociadas";
                    lblConfirmarBaja.Text = "El deporte \"" + nombre + "\" tiene " + canchasActivas + " " + sustantivo
                        + ". Si lo das de baja, esas canchas seguirán activas pero apuntando a un deporte inactivo. ¿Confirmás la baja?";
                }
                else
                {
                    lblConfirmarBaja.Text = "¿Dar de baja el deporte \"" + nombre + "\"?";
                }
                pnlConfirmarBaja.Visible = true;
            }
            else if (e.CommandName == "Reactivar")
            {
                new NegocioDeportes().Reactivar(idDeporte);
                CargarDeportes();
            }
        }

        // Alta: limpia el formulario, deja todo en estado inicial y abre el modal.
        protected void btnNuevo_Click(object sender, EventArgs e)
        {
            hfIdDeporte.Value          = "";
            txtNombre.Text             = "";
            txtDuracion.Text           = "";
            lblErrorDeporte.Visible    = false;
            lblTituloModalDeporte.Text = "Nuevo deporte";

            AbrirModal();
        }

        protected void btnConfirmarBaja_Click(object sender, EventArgs e)
        {
            new NegocioDeportes().BajaLogica(int.Parse(hfBajaId.Value));
            pnlConfirmarBaja.Visible = false;
            CargarDeportes();
        }

        protected void btnCancelarBaja_Click(object sender, EventArgs e)
        {
            pnlConfirmarBaja.Visible = false;
        }

        protected void btnGuardarDeporte_Click(object sender, EventArgs e)
        {
            if (!Page.IsValid) return;

            Deporte deporte = new Deporte
            {
                Nombre          = txtNombre.Text.Trim(),
                DuracionMinutos = int.Parse(txtDuracion.Text),
                Activa          = true
            };

            NegocioDeportes nDeportes = new NegocioDeportes();
            if (string.IsNullOrEmpty(hfIdDeporte.Value))
            {
                nDeportes.Agregar(deporte);
            }
            else
            {
                deporte.IdDeporte = int.Parse(hfIdDeporte.Value);
                nDeportes.Modificar(deporte);
            }

            Response.Redirect("Deportes.aspx");
        }

        protected string FormatearDuracion(object minutosObj)
        {
            return minutosObj + " min por turno";
        }

        protected string GetDeporteEmoji(object nombreObj)
        {
            string nombre = (nombreObj ?? "").ToString().ToLower();
            if (nombre.Contains("fútbol") || nombre.Contains("futbol")) return "⚽";
            if (nombre.Contains("tenis")) return "🎾";
            if (nombre.Contains("básquet") || nombre.Contains("basquet")) return "🏀";
            if (nombre.Contains("pádel") || nombre.Contains("padel")) return "🏓";
            if (nombre.Contains("vóley") || nombre.Contains("voley")) return "🏐";
            return "🏅";
        }

        protected string GetDeporteAccent(object nombreObj)
        {
            string nombre = (nombreObj ?? "").ToString().ToLower();
            if (nombre.Contains("fútbol") || nombre.Contains("futbol")) return "#2d6a4f";
            if (nombre.Contains("tenis")) return "#b5870a";
            if (nombre.Contains("básquet") || nombre.Contains("basquet")) return "#9b4d96";
            if (nombre.Contains("pádel") || nombre.Contains("padel")) return "#1a6fa8";
            if (nombre.Contains("vóley") || nombre.Contains("voley")) return "#c0392b";
            return "#4a5568";
        }

        private void AbrirModal()
        {
            string script =
                "bootstrap.Modal.getOrCreateInstance(document.getElementById('modalNuevoDeporte')).show();";
            ClientScript.RegisterStartupScript(GetType(), "abrirModal", script, true);
        }
    }
}
