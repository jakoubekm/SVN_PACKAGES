<%@ Control Language="C#" AutoEventWireup="true" CodeBehind="PDCStatScheduler.ascx.cs" Inherits="PDC.UserControls.PDCStatScheduler" %>


    <div class="PDCSchStatus rightMe">
<asp:UpdatePanel ID="AJAXUpdatePanelStatSch" runat="server">
<ContentTemplate> 
    <asp:LinkButton ID="lb_StatSCH_Toggle" runat="server" CssClass="headerButton" EnableViewState="False" onclick="Button_Toggle_Click">Scheduler</asp:LinkButton>
    <asp:Label ID="l_StatSCH_NUMBER_ON" runat="server" Text="Label" EnableViewState="False"></asp:Label>On
    <asp:Label ID="l_StatSCH_NUMBER_OFF" runat="server" Text="Label" EnableViewState="False"></asp:Label>Off


    <asp:Panel ID="p_StatusSchedulerDetail" runat="server" CssClass="" Visible="False">
        <div class="breaker_portlet">
            &nbsp;</div>
        <asp:GridView ID="GridView1" runat="server" DataSourceID="SqlDataSource_GUI_SCH_STAT"
            GridLines="None" CssClass="PDCTbl" CellPadding="2" CellSpacing="1" 
            EnableViewState="False" AutoGenerateColumns="False">
            <RowStyle CssClass="PDCTblRow" Wrap="False" />
            <SelectedRowStyle CssClass="PDCTblSelRow" />
            <SortedAscendingHeaderStyle CssClass="sort_asc" />
            <SortedDescendingHeaderStyle CssClass="sort_desc" />
            <AlternatingRowStyle CssClass="PDCTblEvenRow" />
            <HeaderStyle CssClass="PDCTblHeader" />
            <Columns>
                <asp:BoundField DataField="PARAM_CD" HeaderText="Scheduler#" />
                <asp:BoundField DataField="STATUS" HeaderText="Status" />
            </Columns>
            <FooterStyle CssClass="PDCTblFooter" />
        </asp:GridView>
    </asp:Panel>

</ContentTemplate>
<Triggers>
    <asp:AsyncPostBackTrigger ControlID="RefreshTimer" EventName="Tick" />
</Triggers>
</asp:UpdatePanel> 

</div>
    <asp:SqlDataSource ID="SqlDataSource_GUI_SCH_STAT" runat="server" ConnectionString="<%$ ConnectionStrings:PDCOracleConnection.connectionString %>"
        
    ProviderName="<%$ ConnectionStrings:PDCOracleConnection.ProviderName %>" SelectCommand="PCKG_GUI.SP_GUI_HEADER_SCH_STAT"
        SelectCommandType="StoredProcedure" 
    OnSelected="SqlDataSource_Procedure_Selected" 
    onselecting="SqlDataSource_Procedure_Selecting" EnableViewState="False">
        <SelectParameters>
            <asp:Parameter Name="SCH_STATUS_OUT" Direction="Output" />
            <asp:Parameter Name="SCH_NUMBER_ON" Direction="Output" DbType="String" Size="255" />
            <asp:Parameter Name="SCH_NUMBER_OFF" Direction="Output" DbType="String" Size="255" />
            <asp:Parameter Name="SELECTED_ENG_ID_IN" Direction="InputOutput" DefaultValue="0" DbType="String" Size="255" />
            <asp:Parameter Name="DEBUG_IN" Direction="Input" DefaultValue="0" DbType="String" />
            <asp:Parameter Name="EXIT_CD_OUT" Direction="Output" DbType="String" Size="255" />
            <asp:Parameter Name="ERRMSG_OUT" Direction="Output" DbType="String" Size="255" />
            <asp:Parameter Name="ERRCODE_OUT" Direction="Output" DbType="String" Size="255" />
            <asp:Parameter Name="ERRLINE_OUT" Direction="Output" DbType="String" Size="255" />
        </SelectParameters>
    </asp:SqlDataSource>